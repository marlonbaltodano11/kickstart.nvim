return {
  "GustavEikaas/easy-dotnet.nvim",
  -- Cargamos el plugin para archivos C#, soluciones y proyectos
  ft = { "cs", "sln", "csproj", "fsproj" },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "mfussenegger/nvim-dap",
  },
  config = function()
    local dotnet = require("easy-dotnet")

    -- dotnet tool install -g EasyDotnet
    -- dotnet tool install -g roslyn-language-server --prerelease
    -- dotnet tool install -g roslyn-language-server --prerelease --source https://pkgs.dev.azure.com/azure-public/vside/_packaging/vs-impl/nuget/v3/index.json

    -- 1. Intentamos heredar de forma segura las capacidades de autocompletado de tu Kickstart
    local has_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
    local capabilities = has_cmp
      and cmp_lsp.default_capabilities()
      or vim.lsp.protocol.make_client_capabilities()

    dotnet.setup({
      managed_terminal = {
        auto_hide = true,
        auto_hide_delay = 2000, -- Un poco más de tiempo para leer si hay errores
      },

      -- CONFIGURACIÓN DE ROSLYN (LSP OFICIAL)
      lsp = {
        enabled = true,
        preload_roslyn = true,
        roslynator_enabled = true,
        easy_dotnet_analyzer_enabled = true,
        config = {
          capabilities = capabilities,
          on_attach = function(client, bufnr)
            -- Reutilizamos la lógica de mapeo de Kickstart
            local map = function(keys, func, desc)
              vim.keymap.set('n', keys, func, { buffer = bufnr, desc = 'LSP C#: ' .. desc })
            end

            map('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
            map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
            map('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
            map('K', vim.lsp.buf.hover, 'Hover Documentation')
            map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
            map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

            -- Atajo extra para ver errores del proyecto completo
            map('<leader>sd', require('telescope.builtin').diagnostic, '[S]earch [D]iagnostics')
          end,
        }
      },

      -- Debugger configurado para Windows (CoreCLR)
      debugger = {
        bin_path = nil,
        adapter_name = "coreclr",
        console = "integratedTerminal",
      },

      -- Test Runner flotante (muy cómodo para no perder el foco)
      test_runner = {
        auto_start_testrunner = true,
        viewmode = "float",
        neotest_integration = false,
      },

      csproj_mappings = true,
      fsproj_mappings = true,
    })
  end
}
