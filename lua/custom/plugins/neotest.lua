return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
    "Issafalcon/neotest-dotnet", -- El adaptador mágico para C#
  },
  config = function()
    -- Configurar Neotest con el adaptador de .NET
    require("neotest").setup({
      adapters = {
        require("neotest-dotnet")({
          -- Aquí puedes personalizar cosas como el comando de dotnet test
          -- pero por defecto funciona perfecto.
        })
      }
    })

    -- Atajos de teclado (Asumiendo que tu tecla <leader> es el Espacio)
    vim.keymap.set('n', '<leader>tr', function() require('neotest').run.run() end, { desc = '[T]est [R]un (Prueba actual)' })
    vim.keymap.set('n', '<leader>tf', function() require('neotest').run.run(vim.fn.expand('%')) end, { desc = '[T]est [F]ile (Archivo completo)' })
    vim.keymap.set('n', '<leader>ts', function() require('neotest').summary.toggle() end, { desc = '[T]est [S]ummary (Panel lateral)' })
    vim.keymap.set('n', '<leader>to', function() require('neotest').output_panel.toggle() end, { desc = '[T]est [O]utput (Consola)' })
  end,
}
