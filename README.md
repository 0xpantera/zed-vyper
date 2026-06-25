# Vyper support for Zed

Minimal Vyper language support for [Zed](https://zed.dev):

- recognizes `.vy` files as Vyper
- uses a pinned [`tree-sitter-vyper-zed`](https://github.com/0xpantera/tree-sitter-vyper-zed) grammar fork based on [`madlabman/tree-sitter-vyper`](https://github.com/madlabman/tree-sitter-vyper)
- provides basic syntax highlighting, bracket matching, outline, indentation, and text objects
- starts [`vyper-lsp`](https://github.com/vyperlang/vyper-lsp), preferring an executable on `PATH` and falling back to an extension-local `uv` virtual environment

The automatic fallback keeps the user's global Python tools untouched. If neither `vyper-lsp` nor `uv` is on `PATH`, Zed will show an installation error with the manual install command below.

## Local development

Install Rust via `rustup`. Zed compiles Rust extensions to WebAssembly, so the
`wasm32-wasip2` Rust target must be installed. This repository includes a
`rust-toolchain.toml` that asks rustup for that target; if Zed still reports
`can't find crate for core`, install it manually:

```sh
rustup target add wasm32-wasip2
```

Then from this repository:

```sh
cargo check
cargo build --target wasm32-wasip2
```

To validate the pinned grammar outside Zed:

```sh
scripts/validate.sh
```

For LSP support, install `vyper-lsp` separately and ensure it is on `PATH`:

```sh
# Recommended when uv is available:
uv tool install git+https://github.com/vyperlang/vyper-lsp.git

# Or with pipx:
pipx install git+https://github.com/vyperlang/vyper-lsp.git

which vyper-lsp
vyper-lsp --stdio
```

Manual installation is optional when `uv` is available: the extension can install `vyper-lsp` into its own local virtual environment on first LSP startup.

## Testing in Zed

Headless validation can check the Rust extension crate, the manifest/config files, and the grammar. Full editor integration still needs a manual Zed check:

1. Open Zed.
2. Run `zed: install dev extension`.
3. Select this repository directory.
4. Open `fixtures/token.vy`.
5. Confirm Zed selects `Vyper`, loads highlighting, shows outline entries, and starts `Vyper LSP` if `vyper-lsp` is installed.
6. If Zed fails with `the wasm32-wasip2 target may not be installed`, run `rustup target add wasm32-wasip2` and retry installing the dev extension.
7. If something else fails, inspect `zed: open log` or launch Zed with `zed --foreground`.

## Grammar note

The current grammar candidate passes its own corpus and parses a modern Vyper smoke fixture with decorators, events, structs, interfaces, storage variables, and keyword arguments. Zed's grammar builder only compiles `src/parser.c` plus `src/scanner.c`, while the upstream grammar ships its external scanner as `src/scanner.cc`, so this extension pins a small fork with an equivalent C scanner. Known language coverage limitations should be tracked as focused follow-up tasks rather than expanding this extension into a grammar rewrite.
