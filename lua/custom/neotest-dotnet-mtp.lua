-- Adapter overlay for CitizenHarris/neotest-dotnet.
-- MTP is invoked through `dotnet test`; keeping argv construction here makes
-- the Neotest setup independent from easy-dotnet's interactive runner.
local M = {}

function M.setup(opts)
  opts = vim.tbl_deep_extend('force', {
    discovery = { enabled = true },
    discovery_root = 'solution',
    dap = { strategy = require('custom.neotest-dotnet-mtp-debug-strategy') },
    dotnet_additional_args = { '--no-restore', '--report-trx' },
  }, opts or {})

  local ok, adapter = pcall(require, 'neotest-dotnet')
  if not ok then
    vim.notify('CitizenHarris/neotest-dotnet could not be loaded', vim.log.levels.ERROR)
    return nil
  end

  return adapter(opts)
end

return M
