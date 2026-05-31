return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    { "stevearc/dressing.nvim", opts = {} },
  },
  keys = {
    { "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "CodeCompanion Chat" },
    { "<leader>aa", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "CodeCompanion Actions" },
  },
  opts = {
    adapters = {
      gemini = function()
        return require("codecompanion.adapters").extend("gemini", {
          name = "gemini",
          env = {
            api_key = os.getenv("GEMINI_API_KEY"),
          },
          schema = {
            model = { default = "gemini-3.1-flash-lite" },
          },
        })
      end,
    },
    strategies = {
      chat = {
        adapter = "gemini",
        model = "gemini-3.1-flash-lite",
      },
      inline = {
        adapter = "gemini",
        model = "gemini-3.1-flash-lite",
      },
    },
  },
}

