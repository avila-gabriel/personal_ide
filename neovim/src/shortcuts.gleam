import gleam/list
import host

fn opts(desc: String) -> host.KeymapOptions {
  host.KeymapOptions(
    noremap: True,
    silent: True,
    expr: False,
    nowait: False,
    script: False,
    unique: False,
    desc: desc,
  )
}

pub fn apply() -> Nil {
  // --- Select all ---
  // <leader>a in normal + visual
  ["n", "v"]
  |> list.each(fn(mode) {
    host.define_keymap(mode, "<leader>a", "ggVG", opts("Select all"))
  })

  // Ctrl+A (normal only)
  host.define_keymap("n", "<C-a>", "ggVG", opts("Select all"))

  // --- Clipboard ---
  // Ctrl+C (visual only) — copy to + register
  host.define_keymap("v", "<C-c>", "\"+y", opts("Copy to clipboard"))

  // --- Remap i/j/k/l in n,v,o modes ---
  let nav_modes = ["n", "v", "o"]
  nav_modes
  |> list.each(fn(m) {
    host.define_keymap(m, "i", "k", opts("Up"))
    host.define_keymap(m, "j", "h", opts("Left"))
    host.define_keymap(m, "k", "j", opts("Down"))
    host.define_keymap(m, "l", "l", opts("Right"))
  })

  // --- Window navigation with Alt + {j,k,i,l} (normal only) ---
  host.define_keymap("n", "<A-j>", "<C-w>h", opts("Win left"))
  host.define_keymap("n", "<A-k>", "<C-w>j", opts("Win down"))
  host.define_keymap("n", "<A-i>", "<C-w>k", opts("Win up"))
  host.define_keymap("n", "<A-l>", "<C-w>l", opts("Win right"))

  // ';' enters insert (normal only)
  host.define_keymap("n", ";", "i", opts("Enter insert"))

  Nil
}
