# Tree-sitter Vyper follow-up gaps

The initial extension intentionally reuses `madlabman/tree-sitter-vyper` instead of starting a grammar rewrite.

Validated grammar revision: `e4d43a8ad1c59fea7c0d4a1c24301829b61694a1`.

## Observed gaps

- Modern typed loop variables such as `for value: uint256 in values:` produce an `ERROR` node. The coverage fixture uses `for value in values:` so extension/query validation can stay green while this grammar gap is tracked separately.

## Follow-up approach

1. Add a focused upstream grammar corpus case for the failing syntax.
2. Update `grammar.js` minimally for that syntax only.
3. Regenerate parser files and run `tree-sitter generate && tree-sitter test`.
4. Update the pinned grammar revision in `extension.toml` after the grammar fix exists in a fork or upstream.
