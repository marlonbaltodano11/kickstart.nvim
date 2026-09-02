local M = {}


function M.setup()
  local neotest = require('neotest')
  local adapter = require('custom.neotest-dotnet-mtp').setup()
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
