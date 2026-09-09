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
  ---@param proj_root string|nil
  ---@param filter_arg string|nil
  ---@param dotnet_additional_args table|nil
  build_spec_utils.create_single_spec = function(position, proj_root, filter_arg, dotnet_additional_args)
    local results_path = vim.fn.tempname() .. '.trx'
    filter_arg = filter_arg or ''
    -- Anclar el run al root resuelto por el adaptador (cwd_root); si no, el
    -- discovery puede subir hasta nvim-data u otro directorio superior.
    local session_cwd = vim.g.neotest_dotnet_cwd_root or vim.uv.cwd() or '.'

    -- 1. Validar que proj_root no se salga del CWD de la sesión para prevenir
    --    escaneos fuera del proyecto
    if proj_root and proj_root ~= '' then
      local norm_proj = vim.fs.normalize(proj_root)
      local norm_cwd = vim.fs.normalize(session_cwd)

      if not vim.startswith(norm_proj, norm_cwd) then
        proj_root = session_cwd
      end
    else
      proj_root = session_cwd
    end

    -- 2. Resolver el archivo .csproj sin realizar búsquedas recursivas profundas
    local csproj = nil
    if proj_root:sub(-7):lower() == '.csproj' then
      local stat = vim.uv.fs_stat(proj_root)
      if stat and stat.type == 'file' then
        csproj = proj_root
      end
    else
      -- Búsqueda PLANA (solo en la raíz de proj_root, sin subcarpetas)
      local matches = vim.fn.glob(vim.fs.joinpath(proj_root, '*.csproj'), true, true)
      if type(matches) == 'table' and #matches > 0 then
        csproj = matches[1]
      end
    end

    csproj = csproj or proj_root

    -- 3. El cwd del proceso es el directorio del proyecto (o del .csproj),
    --    para que rutas relativas, runsettings, etc. resuelvan ahí.
    local cwd = proj_root
    local csproj_stat = vim.uv.fs_stat(csproj)
    if csproj ~= proj_root and csproj_stat and csproj_stat.type == 'file' then
      cwd = vim.fs.dirname(csproj)
    end

    local command = { 'dotnet', 'test', csproj }

    -- 5. Tokenizar filter_arg si contiene banderas con espacios
    if filter_arg ~= '' then
      for token in filter_arg:gmatch('%S+') do
        table.insert(command, token)
      end
    end

    table.insert(command, '--results-directory')
    table.insert(command, vim.fs.dirname(results_path))
    table.insert(command, '--report-trx')
    table.insert(command, '--report-trx-filename')
    table.insert(command, vim.fs.basename(results_path))
    table.insert(command, '--no-progress')
    table.insert(command, '--no-ansi')

    -- 6. Anexar argumentos adicionales, descartando `--logger`/`-logger` (con
    --    su valor) y `--report-trx`/`--report-trx-filename` para que no pisen
    --    el TRX que genera este overlay.
    local skip_value_flags = {
      ['-logger'] = true,
      ['--logger'] = true,
      ['--report-trx'] = true,
      ['--report-trx-filename'] = true,
    }

    if dotnet_additional_args then
      local i = 1
      while i <= #dotnet_additional_args do
        local arg = dotnet_additional_args[i]
        if type(arg) ~= 'string' then
          table.insert(command, arg)
          i = i + 1
        else
          local flag, value = arg:match '^([^=]+)=([^=]*)$'
          if flag and skip_value_flags[flag] then
            -- Forma `--logger=...`: descartar el flag completo.
            i = i + 1
          elseif skip_value_flags[arg] then
            -- Forma `--logger <valor>`: descartar flag y su valor.
            i = i + 2
          else
            table.insert(command, arg)
            i = i + 1
          end
        end
      end
    end

    if vim.g.neotest_dotnet_runsettings_path then
      table.insert(command, '--settings')
      table.insert(command, vim.g.neotest_dotnet_runsettings_path)
    end

    local logger = require('neotest.logging')
    logger.debug('neotest-dotnet: Running tests using command: ' .. table.concat(command, ' '))

    return {
      command = command, -- Array de argumentos para ejecución segura sin errores de shell
      cwd = cwd,
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
