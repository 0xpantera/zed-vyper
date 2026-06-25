# Tree-sitter Vyper follow-up gaps

The initial extension intentionally reuses `madlabman/tree-sitter-vyper` instead of starting a grammar rewrite. The extension currently points at a small `0xpantera/tree-sitter-vyper-zed` fork that adds a C external scanner so Zed's grammar builder can compile the parser.

Validated upstream grammar revision: `e4d43a8ad1c59fea7c0d4a1c24301829b61694a1`.
Validated Zed-compatible grammar revision: `f3aab540fc349f52cd5bffc4ce44fd816cdf7bc1`.

## Observed gaps

- Modern typed loop variables such as `for value: uint256 in values:` produce an `ERROR` node. The coverage fixture uses `for value in values:` so extension/query validation can stay green while this grammar gap is tracked separately.

## Follow-up approach

1. Add a focused upstream grammar corpus case for the failing syntax.
2. Update `grammar.js` minimally for that syntax only.
3. Regenerate parser files and run `tree-sitter generate && tree-sitter test`.
4. Update the pinned grammar revision in `extension.toml` after the grammar fix exists in a fork or upstream.
