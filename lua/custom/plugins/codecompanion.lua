return {
  'olimorris/codecompanion.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    { 'stevearc/dressing.nvim', opts = {} },
    { 'MeanderingProgrammer/render-markdown.nvim', ft = { 'markdown', 'codecompanion' } },
    'ravitemer/codecompanion-history.nvim',
  },
  opts = {
    adapters = {
      http = {
        gemini = function()
          return require('codecompanion.adapters').extend('gemini', {
            name = 'gemini',
            env = {
              api_key = os.getenv 'GEMINI_API_KEY',
            },
            schema = {
              model = { default = 'gemini-3.1-flash-lite-preview' },
            },
          })
        end,
        minimax = function()
          return require('codecompanion.adapters').extend('openai_compatible', {
            name = 'minimax',
            env = {
              api_key = os.getenv 'MINIMAX_API_KEY',
            },
            url = 'https://api.minimax.io/v1/text/chatcompletion_v2',
            schema = {
              model = {
                default = 'MiniMax-M3',
                choices = {
                  'MiniMax-M3',
                  'MiniMax-M2.7',
                  'MiniMax-M2.7-highspeed',
                },
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
        adapter = 'gemini',
      },
      inline = {
        adapter = 'gemini',
      },
    },
    rules = {
      default = {
        description = 'Base rules for assistant behavior',
        prompt = 'Base rules defining the default behavior of the assistant.',
        files = {
          { path = '~/ai-rules.md', parser = 'codecompanion' },
        },
      },
      ['ai-rules'] = {
        description = 'Base rules defining the default behavior of the assistant.',
        prompt = 'Persistent personal rules loaded from ~/ai-rules.md.',
        files = {
          { path = '~/ai-rules.md', parser = 'codecompanion' },
        },
      },
    },
    prompt_library = {
      ["Generate Commit"] = {
        strategy = "chat",
        description = "Generate a semantic commit command based on a git diff",
        opts = {
          short_name = "commit",
          auto_submit = false,
          is_slash_cmd = false,
        },
        prompts = {
          {
            role = "system",
            content = [[You are an expert developer. Your task is to write clear, concise commit messages based on a git diff following the 'Conventional Commits' specification (e.g., feat, fix, refactor, docs, chore). 
You must explain the WHAT and the WHY, not just the HOW. 

CRITICAL RULE: You must output ONLY the final `git commit` CLI command. Do NOT output a raw text block. For any multi-line commit messages (like adding a body or footer), you MUST use multiple `-m` flags instead of actual line breaks. 
Example format: `git commit -m "feat: add user authentication" -m "This introduces the JWT-based auth flow to secure the API endpoints."`

Do not provide any introductory text, markdown formatting, or explanations. Just the exact command.]],
          },
          {
            role = "user",
            content = "@{run_command} Please run the necessary commands to analyze my git diff and generate the appropriate git commit command\n\n",
          },
        },
      },
      ["Generate Pull Request"] = {
        strategy = "chat",
        description = "Generate a detailed description for a Pull Request",
        opts = {
          short_name = "pr",
          auto_submit = false,
          is_slash_cmd = false,
        },
        prompts = {
          {
            role = "system",
            content = [[You are a senior software engineer. Your goal is to write a detailed, professional Pull Request description in Markdown format.
Structure the response with the following sections:
1. **Summary:** A quick overview of the changes.
2. **Key Changes:** A bulleted list of the main modifications.
3. **Motivation and Context:** Why these changes are being made (the problem being solved).
4. **How to Test:** Brief testing instructions.

Use a formal yet approachable tone. Do not include greetings or conversational filler.]],
          },
          {
            role = "user",
            content = "@{run_command} Generate a Pull Request description based the diff between the current branch and the master branch\n\n",
          },
        },
      },
    },
    extensions = {
      history = {
        enabled = true,
        opts = {
          -- Keymap to open history from chat buffer (default: gh)
          keymap = 'gh',
          -- Keymap to save the current chat manually (when auto_save is disabled)
          save_chat_keymap = 'sc',
          -- Save all chats by default (disable to save only manually using 'sc')
          auto_save = true,
          -- Number of days after which chats are automatically deleted (0 to disable)
          expiration_days = 0,
          -- Picker interface (auto resolved to a valid picker)
          picker = 'telescope', --- ("telescope", "snacks", "fzf-lua", or "default")
          ---Optional filter function to control which chats are shown when browsing
          chat_filter = nil, -- function(chat_data) return boolean end
          -- Customize picker keymaps (optional)
          picker_keymaps = {
            rename = { n = 'r', i = '<M-r>' },
            delete = { n = 'd', i = '<M-d>' },
            duplicate = { n = '<C-y>', i = '<C-y>' },
          },
          ---Automatically generate titles for new chats
          auto_generate_title = true,
          title_generation_opts = {
            ---Adapter for generating titles (defaults to current chat adapter)
            adapter = nil, -- "copilot"
            ---Model for generating titles (defaults to current chat model)
            model = nil, -- "gpt-4o"
            ---Number of user prompts after which to refresh the title (0 to disable)
            refresh_every_n_prompts = 0, -- e.g., 3 to refresh after every 3rd user prompt
            ---Maximum number of times to refresh the title (default: 3)
            max_refreshes = 3,
            format_title = function(original_title)
              -- this can be a custom function that applies some custom
              -- formatting to the title.
              return original_title
            end,
          },
          ---On exiting and entering neovim, loads the last chat on opening chat
          continue_last_chat = false,
          ---When chat is cleared with `gx` delete the chat from history
          delete_on_clearing_chat = false,
          ---Directory path to save the chats
          dir_to_save = vim.fn.stdpath 'data' .. '/codecompanion-history',
          ---Enable detailed logging for history extension
          enable_logging = false,

          -- Summary system
          summary = {
            -- Keymap to generate summary for current chat (default: "gcs")
            create_summary_keymap = 'gcs',
            -- Keymap to browse summaries (default: "gbs")
            browse_summaries_keymap = 'gbs',

            generation_opts = {
              adapter = nil, -- defaults to current chat adapter
              model = nil, -- defaults to current chat model
              context_size = 90000, -- max tokens that the model supports
              include_references = true, -- include slash command content
              include_tool_outputs = true, -- include tool execution results
              system_prompt = nil, -- custom system prompt (string or function)
              format_summary = nil, -- custom function to format generated summary e.g to remove <think/> tags from summary
            },
          },

          -- Memory system (requires VectorCode CLI)
          memory = {
            -- Automatically index summaries when they are generated
            auto_create_memories_on_summary_generation = true,
            -- Path to the VectorCode executable
            vectorcode_exe = 'vectorcode',
            -- Tool configuration
            tool_opts = {
              -- Default number of memories to retrieve
              default_num = 10,
            },
            -- Enable notifications for indexing progress
            notify = true,
            -- Index all existing memories on startup
            -- (requires VectorCode 0.6.12+ for efficient incremental indexing)
            index_on_startup = false,
          },
        },
      },
    },
  },
  keys = {
    { '<leader>ac', '<cmd>CodeCompanionChat Toggle<cr>', mode = { 'n', 'v' }, desc = 'CodeCompanion Chat' },
    { '<leader>aa', '<cmd>CodeCompanionActions<cr>', mode = { 'n', 'v' }, desc = 'CodeCompanion Actions' },
  },
}
