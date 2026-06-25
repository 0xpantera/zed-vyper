use std::fs;

use zed_extension_api::{self as zed, process::Command as ProcessCommand, Result};

const VYPER_LSP_BINARY: &str = "vyper-lsp";
const VYPER_LSP_PACKAGE: &str = "git+https://github.com/vyperlang/vyper-lsp.git";
const VYPER_LSP_VENV_DIR: &str = "vyper-lsp-venv";

struct VyperExtension {
    cached_vyper_lsp_path: Option<String>,
}

impl VyperExtension {
    fn venv_python_path() -> String {
        match zed::current_platform().0 {
            zed::Os::Windows => format!("{VYPER_LSP_VENV_DIR}/Scripts/python.exe"),
            zed::Os::Mac | zed::Os::Linux => format!("{VYPER_LSP_VENV_DIR}/bin/python"),
        }
    }

    fn venv_vyper_lsp_path() -> String {
        match zed::current_platform().0 {
            zed::Os::Windows => format!("{VYPER_LSP_VENV_DIR}/Scripts/vyper-lsp.exe"),
            zed::Os::Mac | zed::Os::Linux => format!("{VYPER_LSP_VENV_DIR}/bin/vyper-lsp"),
        }
    }

    fn file_exists(path: &str) -> bool {
        fs::metadata(path).is_ok_and(|stat| stat.is_file())
    }

    fn run_install_command(
        command: &str,
        args: Vec<String>,
        worktree: &zed::Worktree,
    ) -> Result<()> {
        let mut process = ProcessCommand::new(command)
            .args(args.clone())
            .envs(worktree.shell_env());
        let output = process.output()?;
        if output.status == Some(0) {
            return Ok(());
        }

        Err(format!(
            "command failed: {} {}\nstatus: {:?}\nstdout:\n{}\nstderr:\n{}",
            command,
            args.join(" "),
            output.status,
            String::from_utf8_lossy(&output.stdout),
            String::from_utf8_lossy(&output.stderr),
        ))
    }

    fn install_vyper_lsp(
        &mut self,
        language_server_id: &zed::LanguageServerId,
        worktree: &zed::Worktree,
    ) -> Result<String> {
        let server_path = Self::venv_vyper_lsp_path();
        if self.cached_vyper_lsp_path.as_deref() == Some(server_path.as_str())
            && Self::file_exists(&server_path)
        {
            return Ok(server_path);
        }

        if Self::file_exists(&server_path) {
            self.cached_vyper_lsp_path = Some(server_path.clone());
            return Ok(server_path);
        }

        let uv = worktree.which("uv").ok_or_else(|| {
            "vyper-lsp was not found on PATH, and uv is required for automatic installation. Install uv, or install vyper-lsp manually with: uv tool install git+https://github.com/vyperlang/vyper-lsp.git".to_string()
        })?;

        zed::set_language_server_installation_status(
            language_server_id,
            &zed::LanguageServerInstallationStatus::Downloading,
        );

        let python_path = Self::venv_python_path();
        if !Self::file_exists(&python_path) {
            if fs::metadata(VYPER_LSP_VENV_DIR).is_ok() {
                fs::remove_dir_all(VYPER_LSP_VENV_DIR)
                    .map_err(|err| format!("failed to remove stale {VYPER_LSP_VENV_DIR}: {err}"))?;
            }

            Self::run_install_command(
                &uv,
                vec!["venv".to_string(), VYPER_LSP_VENV_DIR.to_string()],
                worktree,
            )?;
        }

        Self::run_install_command(
            &uv,
            vec![
                "pip".to_string(),
                "install".to_string(),
                "--python".to_string(),
                python_path,
                VYPER_LSP_PACKAGE.to_string(),
            ],
            worktree,
        )?;

        if !Self::file_exists(&server_path) {
            return Err(format!(
                "installed vyper-lsp, but expected executable was not found at {server_path}"
            ));
        }

        self.cached_vyper_lsp_path = Some(server_path.clone());
        Ok(server_path)
    }
}

impl zed::Extension for VyperExtension {
    fn new() -> Self {
        Self {
            cached_vyper_lsp_path: None,
        }
    }

    fn language_server_command(
        &mut self,
        language_server_id: &zed::LanguageServerId,
        worktree: &zed::Worktree,
    ) -> Result<zed::Command> {
        let command = if let Some(command) = worktree.which(VYPER_LSP_BINARY) {
            command
        } else {
            self.install_vyper_lsp(language_server_id, worktree)?
        };

        Ok(zed::Command {
            command,
            args: vec!["--stdio".to_string()],
            env: worktree.shell_env(),
        })
    }
}

zed::register_extension!(VyperExtension);
