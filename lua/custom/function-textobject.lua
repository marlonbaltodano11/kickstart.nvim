-- Treesitter-backed textobjects for C# functions and types.
-- Designed to integrate cleanly with mini.ai (registered in init.lua).
local M = {}

local METHOD_TYPES = { 'method_declaration', 'constructor_declaration', 'local_function_statement' }
local TYPE_TYPES = { 'class_declaration', 'interface_declaration', 'record_declaration', 'struct_declaration', 'enum_declaration' }

---Find the nearest ancestor whose type is one of `types`.
---@param types string[]
---@return TSNode|nil
local function find_ancestor(types)
  local node = vim.treesitter.get_node()
  while node do
    for _, target in ipairs(types) do
      if node:type() == target then
        return node
      end
    end
    node = node:parent()
  end
end

---Convert 0-based end-exclusive tree ranges to mini.ai's 1-based region format.
---@param start_row integer
---@param start_col integer
---@param end_row integer
---@param end_col integer
---@return table
local function to_region(start_row, start_col, end_row, end_col)
  local res = {
    from = { line = start_row + 1, col = start_col + 1 },
    to = { line = end_row + 1, col = end_col },
  }
  -- Adjust for row-exclusive, col-0 convention
  if res.to.col == 0 and res.to.line > 1 then
    res.to.line = res.to.line - 1
    local last_line = vim.fn.getline(res.to.line)
    res.to.col = #last_line + 1
  end
  return res
end

---Whole node region in mini.ai's 1-based format.
---@param node TSNode
---@return table
local function whole_region(node)
  local start_row, start_col, end_row, end_col = node:range()
  return to_region(start_row, start_col, end_row, end_col)
end

---Region strictly between open and close nodes.
---@param open_node TSNode
---@param close_node TSNode
---@return table|nil
local function region_between(open_node, close_node)
  local _, _, open_end_row, open_end_col = open_node:range()
  local close_start_row, close_start_col = close_node:range()

  local region = to_region(open_end_row, open_end_col, close_start_row, close_start_col)

  if region.from.line > region.to.line or (region.from.line == region.to.line and region.from.col >= region.to.col) then
    return nil
  end
  return region
end

---Find the inside region of a declaration (supports blocks and expression bodies =>).
---@param decl_node TSNode
---@return table
local function inside_region(decl_node)
  for child in decl_node:iter_children() do
    local ctype = child:type()

    -- Case 1: Standard block { ... }
    if ctype == 'block' or ctype == 'declaration_list' then
      local open_node, close_node
      for inner in child:iter_children() do
        if inner:type() == '{' then open_node = inner end
        if inner:type() == '}' then close_node = inner end
      end
      if open_node and close_node then
        local region = region_between(open_node, close_node)
        if region then return region end
        return whole_region(child)
      end
    end

    -- Case 2: Expression-bodied members (e.g., => _field;)
    if ctype == 'arrow_expression_clause' then
      local start_row, start_col, end_row, end_col = child:range()
      -- Skip the '=>' symbol (usually 2 characters wide)
      return to_region(start_row, start_col + 2, end_row, end_col)
    end
  end

  return whole_region(decl_node)
end

---Shared walker for textobjects.
---@param types string[]
---@return function
local function make_spec(types)
  return function(ai_type, _, _)
    local node = find_ancestor(types)
    if not node then return {} end
    if ai_type == 'a' then
      return { whole_region(node) }
    end
    return { inside_region(node) }
  end
end

-- Exported specifications for mini.ai integration
M.spec_method = make_spec(METHOD_TYPES)
M.spec_type = make_spec(TYPE_TYPES)

return M
