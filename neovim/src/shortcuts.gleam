import gleam/list
import host

pub fn apply() -> Nil {
  // --- Select all ---
  // <leader>a in normal + visual
  ["n", "v"]
  |> list.each(fn(mode) {
    host.set_shortcut_mode(
      mode,
      "<leader>a",
      "ggVG",
      "{\"desc\":\"Select all\"}",
    )
  })

  // Ctrl+A (normal only)
  host.set_shortcut_mode("n", "<C-a>", "ggVG", "{\"desc\":\"Select all\"}")

  // --- Clipboard ---
  // Ctrl+C (visual only) — copy to + register
  host.set_shortcut_mode(
    "v",
    "<C-c>",
    "\"+y",
    "{\"desc\":\"Copy to clipboard\"}",
  )

  // --- Remap i/j/k/l in n,v,o modes ---
  let nav_modes = ["n", "v", "o"]
  nav_modes
  |> list.each(fn(m) {
    host.set_shortcut_mode(m, "i", "k", "{\"desc\":\"Up\"}")
    host.set_shortcut_mode(m, "j", "h", "{\"desc\":\"Left\"}")
    host.set_shortcut_mode(m, "k", "j", "{\"desc\":\"Down\"}")
    host.set_shortcut_mode(m, "l", "l", "{\"desc\":\"Right\"}")
  })

  // --- Window navigation with Alt + {j,k,i,l} (normal only) ---
  host.set_shortcut_mode("n", "<A-j>", "<C-w>h", "{\"desc\":\"Win left\"}")
  host.set_shortcut_mode("n", "<A-k>", "<C-w>j", "{\"desc\":\"Win down\"}")
  host.set_shortcut_mode("n", "<A-i>", "<C-w>k", "{\"desc\":\"Win up\"}")
  host.set_shortcut_mode("n", "<A-l>", "<C-w>l", "{\"desc\":\"Win right\"}")

  // ';' enters insert (normal only)
  host.set_shortcut_mode("n", ";", "i", "{\"desc\":\"Enter insert\"}")

  Nil
}
