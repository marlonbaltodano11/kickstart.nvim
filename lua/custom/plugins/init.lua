-- Personal plugins configured for Kickstart's vim.pack workflow.

local function add(url)
  vim.pack.add { url }
end

-- CodeCompanion and its integrations.
add 'https://github.com/olimorris/codecompanion.nvim'
add 'https://github.com/ravitemer/codecompanion-history.nvim'
add 'https://github.com/stevearc/dressing.nvim'


require('codecompanion').setup {
  adapters = {
    http = require('custom.plugins.codecompanion.adapters'),
  },
  interactions = require('custom.plugins.codecompanion.interactions'),
  rules = require('custom.plugins.codecompanion.rules'),
  prompt_library = require('custom.plugins.codecompanion.prompts'),
  slash_commands = require('custom.plugins.codecompanion.skills'),
  extensions = require('custom.plugins.codecompanion.extensions'),
}

local codecompanion_keys = require('custom.plugins.codecompanion.keymaps')
for _, mapping in ipairs(codecompanion_keys) do
  vim.keymap.set(mapping.mode or 'n', mapping[1], mapping[2], { desc = mapping.desc })
end

-- Code outline.
add 'https://github.com/stevearc/aerial.nvim'
require('aerial').setup {
  layout = { default_direction = 'right', max_width = { 50, 0.2 }, min_width = 30 },
  filter_kind = false,
  show_linenumbers = false,
  nest_under_parents = true,
  collapse_levels = 3,
  sources = { 'treesitter', 'lsp' },
  open_automatic = false,
}
vim.keymap.set('n', '<leader>ao', '<cmd>AerialToggle!<cr>', { desc = 'Aerial (Code Outline)' })
vim.keymap.set('n', ']m', '<cmd>AerialNext<cr>', { desc = 'Next method/symbol' })
vim.keymap.set('n', '[m', '<cmd>AerialPrev<cr>', { desc = 'Previous method/symbol' })

-- Markdown rendering.
add 'https://github.com/MeanderingProgrammer/render-markdown.nvim'
require('render-markdown').setup {}

-- Git conflict helpers.
add 'https://github.com/akinsho/git-conflict.nvim'
require('git-conflict').setup { default_mappings = true, disable_diagnostics = false }

-- Debugging, including the Windows CoreCLR adapter used by easy-dotnet.
add 'https://github.com/mfussenegger/nvim-dap'
add 'https://github.com/rcarriga/nvim-dap-ui'
add 'https://github.com/nvim-neotest/nvim-nio'
add 'https://github.com/theHamsta/nvim-dap-virtual-text'
local dap = require('dap')
local dapui = require('dapui')
dapui.setup {}
require('nvim-dap-virtual-text').setup {}
dap.listeners.after.event_initialized['dapui_config'] = dapui.open
dap.listeners.before.event_terminated['dapui_config'] = dapui.close
dap.listeners.before.event_exited['dapui_config'] = dapui.close
dap.adapters.coreclr = { type = 'executable', command = 'netcoredbg.exe', args = { '--interpreter=vscode' } }
dap.configurations.cs = {}

-- C# project and test workflow.
add 'https://github.com/GustavEikaas/easy-dotnet.nvim'
local dotnet = require('easy-dotnet')
local capabilities = vim.lsp.protocol.make_client_capabilities()
local has_blink, blink = pcall(require, 'blink.cmp')
if has_blink and blink.get_lsp_capabilities then capabilities = blink.get_lsp_capabilities(capabilities) end
dotnet.setup {
  managed_terminal = { auto_hide = true, auto_hide_delay = 2000 },
  lsp = {
    enabled = true,
    preload_roslyn = true,
    roslynator_enabled = true,
    easy_dotnet_analyzer_enabled = true,
    config = { capabilities = capabilities },
  },
  debugger = { adapter_name = 'coreclr', console = 'integratedTerminal' },
  test_runner = { auto_start_testrunner = false, viewmode = 'float', neotest_integration = false },

  csproj_mappings = true,
  fsproj_mappings = true,
}

vim.keymap.set('n', '<leader>cr', '<cmd>Dotnet run profile Development<cr>', { desc = '[C]sharp [R]un' })
vim.keymap.set('n', '<leader>cs', '<cmd>Dotnet select_project<cr>', { desc = '[C]sharp [S]elect Project' })
vim.keymap.set('n', '<leader>cb', '<cmd>Dotnet build quickfix<cr>', { desc = '[C]sharp [B]uild' })
vim.keymap.set('n', '<leader>cR', '<cmd>Dotnet restore<cr>', { desc = '[C]sharp [R]estore' })
vim.keymap.set('n', '<leader>cC', '<cmd>Dotnet clean<cr>', { desc = '[C]sharp [C]lean' })
vim.keymap.set('n', '<leader>cat', '<cmd>Dotnet test<cr>', { desc = '[C]sharp [T]est' })
vim.keymap.set('n', '<leader>ct', function() require('neotest').run.run() end, { desc = '[C]sharp [T]est' })
vim.keymap.set({ 'n', 'v', 't' }, '<leader>cT', '<cmd>Dotnet terminal toggle<CR>', { desc = '[C]sharp [T]erminal Toggle' })


-- Navigation and diagnostics.
vim.pack.add {
  'https://github.com/folke/flash.nvim',
  'https://github.com/folke/trouble.nvim',
}
require('custom.plugins.flash').setup()
require('custom.plugins.trouble').setup()

vim.pack.add {
  'https://github.com/nvim-neotest/neotest',
  'https://github.com/CitizenHarris/neotest-dotnet',
}
require('custom.plugins.neotest').setup()
