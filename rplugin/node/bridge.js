const path = require('path');
const { pathToFileURL } = require('url');

module.exports = (plugin) => {
  const nvim = plugin.nvim;

  plugin.registerAutocmd('VimEnter', async () => {
    try {
      const hostUrl  = pathToFileURL(
        path.join(__dirname, '../../neovim/build/dev/javascript/neovim/host_ffi.mjs')
      ).href;
      const gleamUrl = pathToFileURL(
        path.join(__dirname, '../../neovim/build/dev/javascript/neovim/main.mjs')
      ).href;

      const host  = await import(hostUrl);
      host.init(plugin);

      const gleam = await import(gleamUrl);
      await gleam.main();

      await nvim.command('echo "[bridge] gleam main() ran"');
    } catch (err) {
      await nvim.command('echoerr "[bridge] ' + String(err).replace(/"/g, '\\"') + '"');
      console.error('[bridge]', err);
    }
  }, { pattern: '*', once: true, sync: true });
};
