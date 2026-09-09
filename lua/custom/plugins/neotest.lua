-- neotest.lua
local M = {}

function M.setup()
  local ok_neotest, neotest = pcall(require, 'neotest')
  if not ok_neotest then
    vim.notify('Neotest could not be loaded', vim.log.levels.ERROR)
    return
  end

  -- 1. Aplicar parches y overlays ANTES de instanciar el adaptador
  local mtp = require('custom.neotest-dotnet-mtp')
  if mtp and mtp.apply then
    mtp.apply()
  end

  -- 2. Cargar la estrategia DAP personalizada
  local ok_debug_strategy, debug_strategy = pcall(require, 'custom.neotest-dotnet-mtp-debug-strategy')
  if not ok_debug_strategy then
    debug_strategy = nil
  end

  -- 3. Instanciar el adaptador de neotest-dotnet.
  --    El adaptador ya resuelve el root por `.csproj`/`.fsproj` (discovery_root='project'),
  --    así que no se sobreescribe `adapter.root`. El cwd de cada run se ancla al root
  --    resuelto para que el discovery no se dispare hacia nvim-data u otro directorio superior.
  local adapter = require('neotest-dotnet') {
    discovery_root = 'project',
    dap = {
      adapter_name = 'coreclr',
      strategy = debug_strategy,
    },
  }

  local original_root = adapter.root
  adapter.root = function(path)
    local root = original_root(path)
    if not root then return nil end
    vim.g.neotest_dotnet_cwd_root = root
    return root
  end

  -- Filter folders for optimized Treesitter/Discovery scanning
  adapter.filter_dir = function(name)
    return name ~= 'bin'
      and name ~= 'obj'
      and name ~= '.git'
      and name ~= 'node_modules'
      and name ~= '.vs'
      and name ~= '.idea'
  end

  -- 4. Inicializar Neotest
  neotest.setup {
    adapters = { adapter },
    discovery = {
      enabled = true,
      concurrent = 1, -- Evita saturar CPU escaneando múltiples proyectos a la vez
    },
  }

  -- Keymaps
  local opts = function(desc)
    return { desc = desc, silent = true }
  end

  vim.keymap.set('n', '<leader>tr', function() neotest.run.run() end, opts('[T]est [R]un Nearest'))
  vim.keymap.set('n', '<leader>tf', function() neotest.run.run(vim.fn.expand '%') end, opts('[T]est [F]ile'))
  vim.keymap.set('n', '<leader>td', function() neotest.run.run { strategy = 'dap' } end, opts('[T]est [D]ebug Nearest'))
  vim.keymap.set('n', '<leader>ts', function() neotest.summary.toggle() end, opts('[T]est [S]ummary'))
  vim.keymap.set('n', '<leader>to', function() neotest.output.open { enter = true } end, opts('[T]est [O]utput float'))
  vim.keymap.set('n', '<leader>tO', function() neotest.output_panel.toggle() end, opts('[T]est [O]utput panel'))
  vim.keymap.set('n', '<leader>tw', function() neotest.watch.toggle() end, opts('[T]est [W]atch nearest'))
  vim.keymap.set('n', '<leader>tx', function() neotest.run.stop() end, opts('[T]est Stop (nearest)'))
  vim.keymap.set('n', ']t', function() neotest.jump.next { status = 'failed' } end, opts('Next [T]est failure'))
  vim.keymap.set('n', '[t', function() neotest.jump.prev { status = 'failed' } end, opts('Previous [T]est failure'))
end

return M
