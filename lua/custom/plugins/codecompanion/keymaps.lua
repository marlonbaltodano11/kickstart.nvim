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
  {
    '<leader>al',
    function() require('codecompanion').toggle_cli() end,
    mode = { 'n', 'v' },
    desc = 'Toggle CodeCompanion CLI (OpenCode)',
  },
}

return keys

