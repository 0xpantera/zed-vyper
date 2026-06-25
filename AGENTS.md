# AGENTS.md

## Purpose

This repository contains a Zed language extension for Vyper.

The goal is boring, reliable editor support:

* recognize `.vy` files
* load a Vyper tree-sitter grammar
* provide basic syntax highlighting
* optionally start `vyper-lsp` when available on PATH

Keep the implementation small unless a task explicitly asks for more.

## Important references

* Zed language extensions: https://zed.dev/docs/extensions/languages
* Zed extension development: https://zed.dev/docs/extensions/developing-extensions
* Zed extension API crate: https://github.com/zed-industries/zed/tree/main/crates/extension_api
* Vyper LSP: https://github.com/vyperlang/vyper-lsp
* Vyper compiler/language: https://github.com/vyperlang/vyper
* Cairo Zed extension: https://github.com/trbutler4/zed-cairo
* Noir Zed extension: https://github.com/shuklaayush/zed-noir

## Local conventions

* Prefer minimal, idiomatic Zed extension structure.
* Pin third-party grammar repositories by commit SHA.
* Do not vendor large external projects unless necessary.
* Do not implement custom LSP installation logic in the first version.
* Assume `vyper-lsp` is installed by the user and available on PATH.
* Keep README instructions clear enough for someone who has built a Zed extension before.

## Tree-sitter

Before creating a new Vyper grammar, inspect existing options, especially:

* https://github.com/madlabman/tree-sitter-vyper

If the grammar is usable, wire it into the extension and add small query files.
If it is stale or incomplete, document the failing syntax cases and create focused follow-up tasks.

Use real Vyper snippets from the official Vyper repo where useful.

## Planning

Use `PLANS.md` only for tasks with meaningful uncertainty or multi-step changes.

For simple edits, do the work directly.

When using a plan:

* keep it short
* update it as facts change
* include validation commands
* avoid speculative architecture
