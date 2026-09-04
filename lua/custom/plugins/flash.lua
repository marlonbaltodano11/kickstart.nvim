local M = {}

function M.setup()
  local flash = require('flash')
  flash.setup {
    modes = { char = { enabled = true } },
  }

  vim.keymap.set({ 'n', 'x', 'o' }, '<leader>j', flash.jump, { desc = 'Flash jump' })
  vim.keymap.set({ 'n', 'x', 'o' }, '<leader>J', flash.treesitter, { desc = 'Flash Treesitter' })
end

return M
