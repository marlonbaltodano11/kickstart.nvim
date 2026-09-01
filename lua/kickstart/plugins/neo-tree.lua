-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

vim.pack.add {
  { src = 'https://github.com/nvim-neo-tree/neo-tree.nvim', version = vim.version.range '*' },
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/MunifTanjim/nui.nvim',
}

vim.keymap.set('n', '\\', '<Cmd>Neotree filesystem left<CR>', { desc = 'NeoTree (CWD)', silent = true })

require('neo-tree').setup {
  filesystem = {
    bind_to_cwd = true,
    cwd_target = 'global',
    window = {
      mappings = {
        ['\\'] = 'close_window',
      },
    },
  },
}
