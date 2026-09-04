-- Treesitter-backed textobjects for C# functions and types.
-- This module is intentionally kept separate so the textobject definitions are
-- reusable by mini.ai without making `inner` and `outer` point to the same node.
local M = {}

local METHOD_TYPES = { 'method_declaration', 'constructor_declaration' }
local TYPE_TYPES = { 'class_declaration', 'interface_declaration', 'record_declaration', 'struct_declaration' }

---Find the nearest ancestor whose type is one of `types`.
---@param types string[]
---@return TSNode|nil
local function find_ancestor(types)
  local node = vim.treesitter.get_node()
  while node do
    for _, target in ipairs(types) do
      if node:type() == target then return node end
    end
    node = node:parent()
  end
end

---Convert 0-based end-exclusive tree ranges to mini.ai's 1-based region
---format, including its end-of-line adjustment for rows that end at column 0.
local function to_region(start_row, start_col, end_row, end_col)
  local res = {
    from = { line = start_row + 1, col = start_col + 1 },
    to = { line = end_row + 1, col = end_col },
  }
  -- 'row-exclusive, col-0' convention: a `to` at column 0 means the whole
  -- previous row, so it is rewritten to the end of that row.
  if res.to.col == 0 and res.to.line > 1 then
    res.to.line = res.to.line - 1
    res.to.col = vim.fn.col({ res.to.line, '$' })
  end
  return res
end

---Whole node region in mini.ai's 1-based line/byte-column format.
---@param node TSNode
---@return table
local function whole_region(node)
  local start_row, start_col, end_row, end_col = node:range()
  return to_region(start_row, start_col, end_row, end_col)
end

---Region strictly between the '{' and '}' child nodes.
---Returns nil when the braces are empty (which would otherwise invert the range).
---@param open_node TSNode
---@param close_node TSNode
---@return table|nil
local function region_between(open_node, close_node)
  local _, _, open_end_row, open_end_col = open_node:range()
  local close_start_row, close_start_col = close_node:range()

  local region = to_region(open_end_row, open_end_col, close_start_row, close_start_col)

  if region.from.line > region.to.line or (region.from.line == region.to.line and region.from.col >= region.to.col) then return nil end
  return region
end

---Find the '{'/'}' pair in a declaration's body (block or declaration_list)
---and return the inside region. Empty braces fall back to the body node;
---declarations without a body fall back to the whole declaration.
---@param decl_node TSNode
---@return table
local function inside_region(decl_node)
  for child in decl_node:iter_children() do
    if child:type() == 'block' or child:type() == 'declaration_list' then
      local open_node, close_node
      for inner in child:iter_children() do
        if inner:type() == '{' then open_node = inner end
        if inner:type() == '}' then close_node = inner end
      end
      if open_node and close_node then
        local region = region_between(open_node, close_node)
        if region then return region end
        return whole_region(child) -- empty {} -> select the body node
      end
    end
  end
  return whole_region(decl_node)
end

---Shared walker for both method (`m`) and type (`F`/`c`) textobjects.
---@param types string[]
---@return function
local function make_spec(types)
  return function(ai_type, _, _)
    local node = find_ancestor(types)
    if not node then return {} end
    if ai_type == 'a' then return { whole_region(node) } end
    return { inside_region(node) }
  end
end

function M.setup()
  local ai = require('mini.ai')
  ai.setup {
    mappings = {
      around_next = 'aa',
      inside_next = 'ii',
    },
    custom_textobjects = {
      m = make_spec(METHOD_TYPES),
      F = make_spec(TYPE_TYPES),
      c = make_spec(TYPE_TYPES),
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
