-- Adapter overlay for CitizenHarris/neotest-dotnet.
-- MTP is invoked through `dotnet test`; keeping argv construction here makes
-- the Neotest setup independent from easy-dotnet's interactive runner.
local M = {}

---Patch the LIVE neotest-dotnet module so `dotnet test` emits a TRX report
---without a logger, while keeping the MTP interactive flow out of the way.
---@return table|nil
function M.apply()
  local ok, adapter = pcall(require, 'neotest-dotnet')
  if not ok then
    vim.notify('CitizenHarris/neotest-dotnet could not be loaded', vim.log.levels.ERROR)
    return nil
  end

  local build_spec_utils = require('neotest-dotnet.utils.build-spec-utils')

  ---@param position table
  ---@param proj_root string
  ---@param filter_arg string
  ---@param dotnet_additional_args table|nil
  build_spec_utils.create_single_spec = function(position, proj_root, filter_arg, dotnet_additional_args)
    local results_path = vim.fn.tempname() .. '.trx'
    filter_arg = filter_arg or ''

    -- Resolve the project to test: a .csproj file is used as-is, otherwise
    -- the first .csproj found in the project directory is used.
    local csproj = proj_root
    if proj_root and proj_root:sub(-7):lower() == '.csproj' then
      local stat = vim.uv.fs_stat(proj_root)
      if not stat or stat.type ~= 'file' then csproj = nil end
    else
      csproj = nil
    end

    if not csproj then
      local matches = vim.fn.glob(vim.fs.joinpath(proj_root or '', '*.csproj'), true, true)
      if type(matches) == 'table' and #matches > 0 then csproj = matches[1] end
    end
    csproj = csproj or proj_root

    local command = { 'dotnet', 'test', csproj }

    if filter_arg ~= '' then table.insert(command, filter_arg) end

    table.insert(command, '--results-directory')
    table.insert(command, vim.fs.dirname(results_path))
    table.insert(command, '--report-trx')
    table.insert(command, '--report-trx-filename')
    table.insert(command, vim.fs.basename(results_path))
    table.insert(command, '--no-progress')
    table.insert(command, '--no-ansi')

    if dotnet_additional_args then
      local i = 1
      while i <= #dotnet_additional_args do
        local arg = dotnet_additional_args[i]
        if arg == '-logger' or arg == '--logger' then
          -- Drop the logger flag together with its value.
          i = i + 2
        elseif type(arg) == 'string' and vim.startswith(arg, '--logger=') then
          i = i + 1
        else
          table.insert(command, arg)
          i = i + 1
        end
      end
    end

    if vim.g.neotest_dotnet_runsettings_path then
      table.insert(command, '--settings')
      table.insert(command, vim.g.neotest_dotnet_runsettings_path)
    end

    local command_string = table.concat(command, ' ')
    local logger = require('neotest.logging')
    logger.debug('neotest-dotnet: Running tests using command: ' .. command_string)

    return {
      command = command_string,
      context = {
        results_path = results_path,
        file = position.path,
        id = position.id,
      },
    }
  end

  -- Ensure the c_sharp parser is loaded before discovery so Roslyn-less
  -- environments still produce a treesitter tree.
  local original_discover_positions = adapter.discover_positions
  adapter.discover_positions = function(path)
    vim.treesitter.language.add('c_sharp')
    return original_discover_positions(path)
  end

  -- Honor the wired `dap.strategy`; the adapter otherwise hardcodes its
  -- netcoredbg strategy and ignores `dap.strategy`.
  local original_build_spec = adapter.build_spec
  adapter.build_spec = function(args)
    local specs = original_build_spec(args)
    if type(args.strategy) == 'string' and args.strategy == 'dap' and specs and specs[1] and specs[1].dap and specs[1].dap.strategy then
      specs[1].strategy = specs[1].dap.strategy
    end
    return specs
  end

  return adapter
end

return M
