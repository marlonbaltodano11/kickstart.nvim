local M = {}

function M.setup()
  local flash = require('flash')
  flash.setup {
    modes = { char = { enabled = true } },
    char = {
      enabled = true,
      -- Show jump labels for f/F/t/T but never steal `s` (search stays `s`).
      jump_labels = true,
      label = { exclude = 'hjkliardc' },
    },
  }

  vim.keymap.set({ 'n', 'x', 'o' }, '<leader>j', flash.jump, { desc = 'Flash jump' })
  vim.keymap.set({ 'n', 'x', 'o' }, '<leader>J', flash.treesitter, { desc = 'Flash Treesitter' })
end

return M
