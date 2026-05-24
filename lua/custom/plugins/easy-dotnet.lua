return {
  "GustavEikaas/easy-dotnet.nvim",
  -- Forzamos a que cargue cuando abras la solución o código C#
  ft = { "cs", "sln", "csproj" },
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
        auto_hide_delay = 1000,
      },

      -- 🚀 AQUÍ ESTÁ TU NUEVO LSP DE ROSLYN OFICIAL
      lsp = {
        enabled = true,            -- Reemplaza por completo a csharp-ls
        preload_roslyn = true,     -- Indexa el código rápido al arrancar
        roslynator_enabled = true, -- Analizador de código de Microsoft activo
        easy_dotnet_analyzer_enabled = true,

        -- Inyectamos la configuración del servidor nativo de Neovim
        config = {
          capabilities = capabilities,
          -- Mapeamos tus atajos de teclado indispensables para navegar el código
          on_attach = function(client, bufnr)
            local map = function(keys, func, desc)
              vim.keymap.set('n', keys, func, { buffer = bufnr, desc = 'LSP C#: ' .. desc })
            end

            map('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
            map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
            map('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
            map('K', vim.lsp.buf.hover, 'Hover Documentation')
            map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
            map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          end,
        }
      },

      -- Tu Debugger listo
      debugger = {
        bin_path = nil,
        adapter_name = "coreclr",
        console = "integratedTerminal",
      },

      -- Tu Test Runner listo (el árbol visual con la tecla 'o')
      test_runner = {
        auto_start_testrunner = true,
        viewmode = "float",
        neotest_integration = false,
      },

      csproj_mappings = true,
      fsproj_mappings = true,
    })

    -- Atajos globales para ejecutar comandos de la solución multiproyecto
    local map = vim.keymap.set
    map("n", "<leader>ct", "<cmd>Dotnet testrunner<CR>", { desc = "[T]est [D]otnet Runner" })
    map("n", "<leader>cs", "<cmd>Dotnet solution select<CR>", { desc = "[S]olution [S]elect" })
  end
}
