#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GRAMMAR_REPO="https://github.com/0xpantera/tree-sitter-vyper-zed"
GRAMMAR_REV="f3aab540fc349f52cd5bffc4ce44fd816cdf7bc1"
GRAMMAR_DIR="${TREE_SITTER_VYPER_DIR:-}"

if [[ -z "$GRAMMAR_DIR" ]]; then
  GRAMMAR_DIR="$(mktemp -d /tmp/tree-sitter-vyper.XXXXXX)"
  git clone --quiet "$GRAMMAR_REPO" "$GRAMMAR_DIR"
  git -C "$GRAMMAR_DIR" checkout --quiet "$GRAMMAR_REV"
fi

cd "$ROOT"
python3 - <<'PY'
from pathlib import Path
import tomllib
for path in ["extension.toml", "Cargo.toml", "languages/vyper/config.toml"]:
    tomllib.loads(Path(path).read_text())
print("manifest/config TOML ok")
PY

cargo fmt --check
cargo check
if ! rustup target list --installed | grep -qx "wasm32-wasip2"; then
  echo "Installing missing Rust target: wasm32-wasip2"
  rustup target add wasm32-wasip2
fi
cargo build --target wasm32-wasip2

cd "$GRAMMAR_DIR"
pnpm dlx tree-sitter-cli@0.20.8 generate
pnpm dlx tree-sitter-cli@0.20.8 test

for fixture in "$ROOT"/fixtures/*.vy; do
  echo "parse $(basename "$fixture")"
  pnpm dlx tree-sitter-cli@0.20.8 parse "$fixture" >"/tmp/zed-vyper-$(basename "$fixture").parse"
  if grep -q "ERROR" "/tmp/zed-vyper-$(basename "$fixture").parse"; then
    echo "tree-sitter parse produced ERROR nodes for $fixture" >&2
    exit 1
  fi

done

for query in highlights brackets indents outline textobjects; do
  for fixture in "$ROOT"/fixtures/*.vy; do
    pnpm dlx tree-sitter-cli@0.20.8 query "$ROOT/languages/vyper/${query}.scm" "$fixture" >/tmp/zed-vyper-query-${query}.out
  done
  echo "query $query ok"
done

if command -v vyper-lsp >/dev/null 2>&1; then
  python3 "$ROOT/scripts/vyper_lsp_smoke.py"
else
  echo "vyper-lsp not on PATH; skipping LSP smoke"
fi
