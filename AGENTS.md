# AGENTS GUIDE
1. Use cmd extras: `rga` for ripgrep and `ctx` for quick context dumps (generated `code_context.md` at `.`).
2. Run full test suite using `gleam test` at `neovim/`.
3. JS FFI sticks to semicolons, single quotes, and async/await error guards as in `rplugin/node/bridge.js`.
4. Order Gleam imports with stdlib (`gleam/*`) before local modules; drop unused ones.
5. Prefer pipelines for collection transforms and keep functions small and pure.
6. Handle errors via Gleam `Result` or descriptive JS `Error`; never swallow exceptions silently.
7. Guard FFI access with `ensure()` (see `host_ffi.mjs`) before calling nvim APIs.
8. Node bridge loads Gleam output from `neovim/build/dev/javascript`; rebuild before trying in Neovim (´gleam build´ at neovim/).
9. No comments in code, unless its a unobvious decision that must be explicitly pointed.
10. No Cursor or Copilot rules detected; rely solely on this guide.
11. Keep this playbook current when tooling or workflows change.

