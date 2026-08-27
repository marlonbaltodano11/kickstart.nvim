-- Keymaps de CodeCompanion

local keys = {
  {
    '<leader>ac',
    '<cmd>CodeCompanionChat Toggle<cr>',
    mode = { 'n', 'v' },
    desc = 'CodeCompanion Chat',
  },
  {
    '<leader>aa',
    '<cmd>CodeCompanionActions<cr>',
    mode = { 'n', 'v' },
    desc = 'CodeCompanion Actions',
  },
}

return keys