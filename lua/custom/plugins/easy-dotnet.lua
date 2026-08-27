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

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    local has_blink, blink = pcall(require, "blink.cmp")
    if has_blink and blink.get_lsp_capabilities then
      capabilities = blink.get_lsp_capabilities(capabilities)
    end

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
            -- Code actions use the general LSP mapping `<leader>.`; keep the C# namespace for tests/builds.

            map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')


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
