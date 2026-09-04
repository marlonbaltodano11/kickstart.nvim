local M = {}


function M.setup()
  local neotest = require('neotest')

  local cwd_root = vim.fs.normalize(vim.fn.getcwd())
  local root_prefix = cwd_root .. '/'

  -- Keep Neotest rooted at the directory Neovim was started in. `path` is a
  -- file or directory; resolve it to the CWD root only when it is that root
  -- or one of its descendants. `vim.fs.normalize` uses forward slashes on
  -- Windows, so the child check must use the same separator.
  local function resolve_project(path)
    path = vim.fs.normalize(path or '')
    local stat = vim.uv.fs_stat(path)
    if stat and stat.type == 'file' then path = vim.fs.dirname(path) end
    if path == cwd_root or vim.startswith(path, root_prefix) then return cwd_root end
    return nil
  end

  local adapter = require('neotest-dotnet') {
    discovery_root = 'project',
    dap = {
      adapter_name = 'coreclr',
      strategy = require('custom.neotest-dotnet-mtp-debug-strategy'),
    },
  }

  adapter.root = function(path) return resolve_project(path) end
  adapter.filter_dir = function(name)
    return name ~= 'bin' and name ~= 'obj' and name ~= '.git' and name ~= 'node_modules'
  end

  require('custom.neotest-dotnet-mtp').apply()

  neotest.setup {
    adapters = { adapter },
    discovery = { enabled = true },
  }

  vim.keymap.set('n', '<leader>tr', function() neotest.run.run() end, { desc = '[T]est [R]un' })
  vim.keymap.set('n', '<leader>tf', function() neotest.run.run(vim.fn.expand '%') end, { desc = '[T]est [F]ile' })
  vim.keymap.set('n', '<leader>ts', function() neotest.summary.toggle() end, { desc = '[T]est [S]ummary' })
  vim.keymap.set('n', '<leader>to', function() neotest.output_panel.toggle() end, { desc = '[T]est [O]utput' })
end

return M
