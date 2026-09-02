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
      m = function(ai_type, _, _)
        if vim.bo.filetype ~= 'cs' then
          return ai.gen_spec.treesitter {
            a = '@method_declaration.outer',
            i = '@method_declaration.inner',
          }(ai_type)
        end

        local node = vim.treesitter.get_node()
        while node do
          local node_type = node:type()
          if node_type == 'method_declaration' or node_type == 'constructor_declaration' then
            local start_row, start_col, end_row, end_col = node:range()
            local region
            if ai_type == 'a' then
              region = {
                from = { line = start_row + 1, col = start_col + 1 },
                to = { line = end_row + 1, col = end_col },
              }
            else
              for child in node:iter_children() do
                if child:type() == 'block' then
                  local block_start_row, block_start_col, block_end_row, block_end_col = child:range()
                  region = {
                    from = { line = block_start_row + 1, col = block_start_col + 2 },
                    to = { line = block_end_row + 1, col = block_end_col - 1 },
                  }
                  break
                end
              end
            end
            if region then return { region } end
          end
          node = node:parent()
        end
        return {}
      end,
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
