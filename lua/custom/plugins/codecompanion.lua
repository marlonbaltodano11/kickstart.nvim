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
      http = {
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
        minimax = function()
          return require("codecompanion.adapters").extend("openai_compatible", {
            name = "minimax",
            env = {
              api_key = os.getenv("MINIMAX_API_KEY"),
            },
            url = "https://api.minimax.io/v1/text/chatcompletion_v2",
            schema = {
              model = {
                default = "MiniMax-M3",
                choices = {
                  "MiniMax-M3",
                  "MiniMax-M2.7",
                  "MiniMax-M2.7-highspeed",
                }
              },
            },
            opts = {
              stream = false,
            },
          })
        end,
      },
    },
    strategies = {
      chat = {
        adapter = "gemini",
      },
      inline = {
        adapter = "gemini",
      },
    },
    rules = {
      default = {
        description = "Reglas base para el comportamiento del asistente",
        prompt = "Reglas base que definen el comportamiento por defecto del asistente.",
        "ai-rules",
      },
      ["ai-rules"] = {
        description = "Reglas personales persistentes",
        prompt = "Reglas personales persistentes cargadas desde ~/ai-rules.md.",
        files = {
          { path = "~/ai-rules.md", parser = "codecompanion" },
        },
      },
    },
  },
  keys = {
    { "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "CodeCompanion Chat" },
    { "<leader>aa", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "CodeCompanion Actions" },
  },
}

