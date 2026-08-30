-- Treesitter-backed textobjects for functions and classes.
-- This module is intentionally kept separate so the textobject definitions are
-- reusable by mini.ai without making `inner` and `outer` point to the same node.
local M = {}

function M.setup()
  local ai = require('mini.ai')
  ai.setup {
    mappings = {
      around_next = 'aa',
      inside_next = 'ii',
    },
    custom_textobjects = {
      m = ai.gen_spec.treesitter {
        a = '@method_declaration.outer',
        i = '@method_declaration.inner',
      },
      F = ai.gen_spec.treesitter { a = '@function.outer', i = '@function.inner' },
      c = ai.gen_spec.treesitter { a = '@class.outer', i = '@class.inner' },
    },
    n_lines = 500,
  }

  -- Mnemonics for the most common yank variants. `yam`/`yim` remain genuine
  -- operator-pending textobjects, so d/c/v work with them as well.
  vim.keymap.set('n', '<leader>ym', 'yam', { remap = true, desc = 'Yank around method' })
  vim.keymap.set('n', '<leader>yi', 'yim', { remap = true, desc = 'Yank inside method' })
  vim.keymap.set('n', '<leader>yc', 'yac', { remap = true, desc = 'Yank around class' })
end

return M
