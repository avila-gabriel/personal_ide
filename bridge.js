import * as host from './neovim/src/host.mjs';

import * as gleam from 'neovim/build/dev/javascript/neovim/main.mjs';
export default (plugin) => {
  host._init(plugin);

  if (typeof gleam.init === 'function') {
    gleam.main();
  }
};