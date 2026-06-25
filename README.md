# Vyper support for Zed

Minimal Vyper language support for [Zed](https://zed.dev):

- recognizes `.vy` files as Vyper
- uses the pinned [`madlabman/tree-sitter-vyper`](https://github.com/madlabman/tree-sitter-vyper) grammar
- provides basic syntax highlighting, bracket matching, outline, indentation, and text objects
- optionally starts [`vyper-lsp`](https://github.com/vyperlang/vyper-lsp) when it is available on `PATH`

This first version intentionally does **not** download or install `vyper-lsp` for the user.

## Local development

Install Rust via `rustup`, then from this repository:

```sh
cargo check
cargo build --target wasm32-wasip2
```

If the `wasm32-wasip2` target is missing:

```sh
rustup target add wasm32-wasip2
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

## Testing in Zed

Headless validation can check the Rust extension crate, the manifest/config files, and the grammar. Full editor integration still needs a manual Zed check:

1. Open Zed.
2. Run `zed: install dev extension`.
3. Select this repository directory.
4. Open `fixtures/token.vy`.
5. Confirm Zed selects `Vyper`, loads highlighting, shows outline entries, and starts `Vyper LSP` if `vyper-lsp` is installed.
6. If something fails, inspect `zed: open log` or launch Zed with `zed --foreground`.

## Grammar note

The current grammar candidate passes its own corpus and parses a modern Vyper smoke fixture with decorators, events, structs, interfaces, storage variables, and keyword arguments. Known limitations should be tracked as focused follow-up tasks rather than expanding this extension into a grammar rewrite.
