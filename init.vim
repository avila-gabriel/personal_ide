" === Minimal settings ===
set number
syntax on

" === Point Neovim to Node (adjust if needed; run `where node`) ===
let g:node_host_prog = 'C:\Program Files\nodejs\node.exe'

" === Register/refresh Node remote plugins ===
" Run this once after you create/change rplugin files.
" You can leave it here; it won't hurt if it runs again.
command! ReloadRemotePlugins :UpdateRemotePlugins
