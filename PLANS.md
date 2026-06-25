# PLANS.md

# Minimal ExecPlan Guidelines

Use an ExecPlan only when a task is too large or ambiguous to execute directly.

This repo should usually not need long plans. Zed language extensions are small, and the first goal is a minimal working Vyper extension.

## When to write a plan

Write a short plan for:

* evaluating or replacing the Vyper tree-sitter grammar
* adding non-trivial LSP installation/download behavior
* changing repo structure
* preparing an upstream PR to Zed extensions
* debugging a failure that spans grammar, queries, and extension API code

Do not write a plan for:

* adding one query
* fixing a typo
* updating README wording
* changing a manifest field
* adding one config option

## Plan format

Use this structure:

```md
# Plan: <short title>

## Goal
One paragraph.

## Current facts
- What is known from the repo.
- What is known from docs or reference repos.
- What is still unknown.

## Steps
1. Small concrete step.
2. Small concrete step.
3. Small concrete step.

## Validation
- Commands to run.
- Manual Zed check if needed.

## Done when
- Observable working result.
```

## Rules

* Keep plans under ~80 lines.
* Prefer code and tests over planning.
* Do not invent requirements.
* Update the plan when reality differs from assumptions.
* End with a concise summary of what changed and what remains.

# Plan: Initial Vyper language extension

## Goal
Create the smallest useful Zed extension that recognizes `.vy` files, loads a pinned Vyper tree-sitter grammar, provides basic editor queries, and starts `vyper-lsp` from PATH when available.

## Current facts
- This workspace initially contained only `AGENTS.md` and `PLANS.md`; it is not currently a git repository.
- Zed language extensions use `extension.toml`, `languages/<name>/config.toml`, tree-sitter queries, and optional Rust code for language servers.
- `madlabman/tree-sitter-vyper` at `e4d43a8ad1c59fea7c0d4a1c24301829b61694a1` passes its corpus with `tree-sitter-cli@0.20.8` and parses a modern Vyper smoke fixture without `ERROR` nodes.

## Steps
1. Add extension manifest and Rust crate metadata.
2. Add `languages/vyper` config and minimal queries.
3. Add Rust extension code that resolves `vyper-lsp` via `worktree.which("vyper-lsp")` and starts it without installer logic.
4. Add README, license, fixture, and ignore rules.
5. Run non-GUI validation.

## Validation
- `pnpm dlx tree-sitter-cli@0.20.8 test` in the grammar checkout.
- `pnpm dlx tree-sitter-cli@0.20.8 parse fixtures/token.vy` against the grammar.
- `cargo check`.
- `cargo build --target wasm32-wasip2` when the target is available or can be installed.
- Inspect `extension.toml` and language config against Zed docs.

## Done when
- The extension files exist, non-GUI validation results are recorded, and remaining manual Zed checks are listed for the maintainer.
