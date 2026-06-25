use zed_extension_api::{self as zed, Result};

struct VyperExtension;

impl zed::Extension for VyperExtension {
    fn new() -> Self {
        Self
    }

    fn language_server_command(
        &mut self,
        _language_server_id: &zed::LanguageServerId,
        worktree: &zed::Worktree,
    ) -> Result<zed::Command> {
        let command = worktree
            .which("vyper-lsp")
            .ok_or_else(|| "vyper-lsp must be installed and available on PATH".to_string())?;

        Ok(zed::Command {
            command,
            args: vec!["--stdio".to_string()],
            env: worktree.shell_env(),
        })
    }
}

zed::register_extension!(VyperExtension);
