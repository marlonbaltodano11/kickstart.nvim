local M = {}

function M.setup()
  require('trouble').setup {}

  local trouble = require('trouble')
  vim.keymap.set('n', '<leader>xx', function() trouble.toggle { mode = 'diagnostics', focus = true } end, { desc = 'Diagnostics (Trouble)' })
  vim.keymap.set('n', '<leader>xX', function() trouble.toggle { mode = 'diagnostics', filter = { buf = 0 }, focus = true } end, { desc = 'Buffer diagnostics (Trouble)' })
  vim.keymap.set('n', '<leader>xq', function() trouble.toggle { mode = 'quickfix', focus = true } end, { desc = 'Quickfix (Trouble)' })
  vim.keymap.set('n', '<leader>xl', function() trouble.toggle { mode = 'loclist', focus = true } end, { desc = 'Location list (Trouble)' })
end

return M
