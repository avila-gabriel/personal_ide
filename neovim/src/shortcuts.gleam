import gleam/list
import host

pub fn apply() -> Nil {
  let modes = ["n", "v", "o"]

  modes
  |> list.each(fn(mode) {
    host.set_keymap_default(mode, "i", "k")
    host.set_keymap_default(mode, "j", "h")
    host.set_keymap_default(mode, "k", "j")
    host.set_keymap_default(mode, "l", "l")
  })

  host.set_keymap_default("n", "<A-j>", "<C-w>h")
  host.set_keymap_default("n", "<A-k>", "<C-w>j")
  host.set_keymap_default("n", "<A-i>", "<C-w>k")
  host.set_keymap_default("n", "<A-l>", "<C-w>l")

  host.set_keymap_default("n", ";", "i")

  host.set_global_option("clipboard", "unnamedplus")

  host.set_keymap_with_desc("n", "<C-a>", "ggVG", "Select all")
  host.set_keymap_with_desc("v", "<C-c>", "\"+y", "Copy to clipboard")
  host.set_keymap_with_desc("n", "<C-v>", "\"+p", "Paste clipboard")
  host.set_keymap_with_desc("i", "<C-v>", "<C-r>+", "Paste clipboard")
  host.set_keymap_with_desc(
    "v",
    "<C-v>",
    "\"+p",
    "Replace selection with clipboard",
  )

  Nil
}
