-- Neotest debug strategy must always return a strategy object. Returning nil
-- makes Neotest crash while dispatching a debug request.
local M = {}

function M.get_strategy(_position, _adapter, _args)
  local dap = require('dap')
  return function()
    local session = dap.run(vim.tbl_deep_extend('force', {
      type = 'coreclr',
      request = 'launch',
      name = 'Neotest .NET test (MTP)',
      program = function() return vim.fn.input('Test assembly: ', vim.fn.getcwd() .. '/', 'file') end,
      cwd = vim.fn.getcwd(),
      console = 'integratedTerminal',
    }, _args or {}))
    return session
  end
end

return M
