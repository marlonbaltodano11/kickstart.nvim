-- Neotest debug strategy for .NET (MTP).
--
-- A strategy must return a `neotest.Process` with the fields below.
-- `dap.run()` returns a DAP *session*, not a Process, so returning it directly
-- makes Neovim crash while dispatching a debug request. Instead we delegate to
-- Neotest's built-in DAP strategy, which wraps the session in a Process.
local function completed_process(result)
  local output = vim.fn.tempname()
  local f = io.open(output, 'w')
  if f then
    f:write('DAP strategy is not available\n')
    f:close()
  end
  return {
    is_complete = function() return true end,
    result = function() return result or 1 end,
    output = function() return output end,
    output_stream = function()
      local sent = false
      return function()
        if sent then return nil end
        sent = true
        return 'DAP strategy is not available\n'
      end
    end,
    attach = function() end,
    stop = function() end,
  }
end

---@param spec neotest.RunSpec
---@param context neotest.StrategyContext
---@return neotest.Process
return function(spec, context)
  local ok, dap_strategy = pcall(require, 'neotest.client.strategies.dap')
  if not ok or not dap_strategy then return completed_process(1) end

  -- The built-in DAP strategy reads its launch configuration from
  -- `spec.strategy`, so translate the adapter's `spec.dap` options into one.
  local dap_config = spec.dap or {}
  spec.strategy = {
    type = dap_config.adapter_name or 'coreclr',
    request = 'launch',
    name = 'Neotest .NET test (MTP)',
    program = dap_config.program
      or function() return vim.fn.input('Test assembly: ', vim.fn.getcwd() .. '/', 'file') end,
    cwd = dap_config.cwd or vim.fn.getcwd(),
    console = dap_config.console or 'integratedTerminal',
  }
  if type(dap_config.args) == 'table' then
    spec.strategy = vim.tbl_extend('force', spec.strategy, dap_config.args)
  end

  local process = dap_strategy(spec, context)
  if not process then return completed_process(1) end
  return process
end
