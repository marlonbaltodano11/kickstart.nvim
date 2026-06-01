return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    { "stevearc/dressing.nvim", opts = {} },
    { 'MeanderingProgrammer/render-markdown.nvim', ft = { 'markdown', 'codecompanion' } }
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
            model = { default = "gemini-3.1-flash-lite-preview" },
          },
        })
      end,
    },
    strategies = {
      chat = {
        adapter = "gemini",
        model = "gemini-3.1-flash-lite-preview",
      },
      inline = {
        adapter = "gemini",
        model = "gemini-3.1-flash-lite-preview",
      },
    },
  },
  keys = {
    { "<leader>an", "<cmd>CodeCompanionChat adapter=gemini model=gemini-3.1-flash-lite-preview<cr>", mode = { "n", "v" }, desc = "CodeCompanion Chat" },
    { "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "CodeCompanion Chat" },
    { "<leader>aa", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "CodeCompanion Actions" },
  },
}

