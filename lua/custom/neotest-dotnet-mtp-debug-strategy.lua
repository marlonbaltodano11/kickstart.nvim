-- Neotest debug strategy for .NET (MTP).
--
-- A strategy must return a `neotest.Process` with the fields below.
-- `dap.run()` returns a DAP *session*, not a Process, so returning it directly
-- makes Neovim crash while dispatching a debug request. Instead we delegate to
-- Neotest's built-in DAP strategy, which wraps the session in a Process.

---@param result number|nil
---@return neotest.Process
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
  if not ok or not dap_strategy then
    return completed_process(1)
  end

  local cwd = vim.uv.cwd() or vim.fn.getcwd()
  local dap_config = spec.dap or {}

  -- 1. Construir la configuración de lanzamiento del cliente DAP
  local strategy_config = {
    type = dap_config.adapter_name or 'coreclr',
    request = 'launch',
    name = 'Neotest .NET test (MTP)',
    program = dap_config.program or function()
      return vim.fn.input('Test assembly: ', cwd .. '/', 'file')
    end,
    cwd = dap_config.cwd or cwd,
    console = dap_config.console or 'integratedTerminal',
  }

  -- 2. Asignar los argumentos correctamente como la propiedad `args`
  if type(dap_config.args) == 'table' and not vim.tbl_isempty(dap_config.args) then
    strategy_config.args = dap_config.args
  end

  -- 3. Asignar variables de entorno si vienen definidas en el DAP config
  if type(dap_config.env) == 'table' and not vim.tbl_isempty(dap_config.env) then
    strategy_config.env = dap_config.env
  end

  spec.strategy = strategy_config

  -- 4. Delegar en la estrategia DAP nativa de Neotest
  local process = dap_strategy(spec, context)
  if not process then
    return completed_process(1)
  end

  return process
end
