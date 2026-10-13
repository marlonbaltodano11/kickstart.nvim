local M = {}

-- Minuet starts disabled; toggle it with <leader>ai.
local minuet_enabled = false

function M.setup()
  require('minuet').setup {
    -- Blocks automatic completions (virtualtext, cmp, blink, lsp, duet)
    -- while returning false. Manual invocation keeps working.
    enable_predicates = {
      function()
        return minuet_enabled
      end,
    },
    provider = 'openai_compatible',
    request_timeout = 2.5,
    throttle = 1500,
    debounce = 600,
    n_completions = 1,
    notify = 'warn',
    provider_options = {
      openai_compatible = {
        api_key = 'DEEPSEEK_API_KEY',
        end_point = 'https://api.deepseek.com/chat/completions',
        model = 'deepseek-v4-flash',
        name = 'DeepSeek',
        stream = true,
        system = {
          template = '{{{prompt}}}\n{{{guidelines}}}',
          prompt = [[
You are an inline autocomplete engine embedded in a code editor. The text you
output is inserted verbatim at the cursor, exactly as if the user had typed
it, and it must fit naturally into the surrounding code.

The input uses these markers:
- <contextBeforeCursor>: code before the cursor
- <cursorPosition>: where the completion starts
- <contextAfterCursor>: code after the cursor
]],
          guidelines = [[
Guidelines:
1. Predict the exact next characters, words, or lines the user would type at <cursorPosition>.
2. Output only the text to insert. Never explain the code, detect bugs, review, refactor, or suggest alternatives. Never mention being an AI.
3. Never repeat the code that already appears around the cursor, and stop at a natural point (end of line, statement, or block). Do not write code unrelated to the cursor position.
4. Preserve the file's existing indentation, whitespace, and code style exactly.
5. Inside comments or strings, continue the comment or string text in the same tone instead of writing code.
6. Return raw text only, without markdown fences or extra blank lines.
7. The text before <cursorPosition> is already written. If your completion needs a space, newline, or indentation before it, begin the completion with that whitespace instead of repeating the last character.]],
        },
        few_shots = {
          {
            role = 'user',
            content = [[
# language: lua
<contextBeforeCursor>
local function add(a, b)
  return<cursorPosition>
<contextAfterCursor>

]],
          },
          {
            role = 'assistant',
            content = ' a + b',
          },
          {
            role = 'user',
            content = [[
# language: lua
<contextBeforeCursor>
local function double(n)
  if n > 0 then
    return n * 2
  end<cursorPosition>
<contextAfterCursor>

]],
          },
          {
            role = 'assistant',
            content = '\nend',
          },
        },
        optional = {
          max_tokens = 256,
          thinking = { type = 'disabled' },
        },
      },
    },
    virtualtext = {
      auto_trigger_ft = { '*' },
      auto_trigger_ignore_ft = {
        'markdown',
        'text',
        'gitcommit',
        'TelescopePrompt',
        'codecompanion',
        'codecompanion_cli',
        'oil',
        'NvimTree',
        'help',
        'dapui_console',
        'dap-repl',
      },
      keymap = {
        accept = '<A-A>',
        accept_line = '<A-a>',
        accept_n_lines = '<A-z>',
        next = '<A-]>',
        prev = '<A-[>',
        dismiss = '<A-e>',
      },
    },
    presets = {
      openrouter = {
        provider = 'openai_compatible',
        request_timeout = 2.5,
        throttle = 1500,
        debounce = 600,
        provider_options = {
          openai_compatible = {
            api_key = 'OPENROUTER_API_KEY',
            end_point = 'https://openrouter.ai/api/v1/chat/completions',
            model = 'deepseek/deepseek-v4-flash',
            name = 'OpenRouter',
            optional = {
              max_tokens = 56,
              top_p = 0.9,
              provider = { sort = 'throughput' },
              reasoning = { effort = 'none' },
              thinking = vim.NIL,
            },
          },
        },
      },
    },
  }

  local utils = require 'minuet.utils'

  local trim_completion_item = utils.trim_completion_item
  utils.trim_completion_item = function(item, opts)
    if opts and opts.keep_leading_newline then
      item = item:gsub('%s+$', '')
      if not item:find '%S' then
        return nil
      end
      return item
    end
    return trim_completion_item(item, opts)
  end

  utils.trim_completion_items = function(items)
    local result = {}
    for _, item in ipairs(items) do
      item = item:gsub('%s+$', '')
      if item:find '%S' then
        table.insert(result, item)
      end
    end
    return result
  end

  vim.keymap.set('n', '<leader>ai', function()
    minuet_enabled = not minuet_enabled
    vim.notify('Minuet ' .. (minuet_enabled and 'enabled' or 'disabled'), vim.log.levels.INFO)
    if not minuet_enabled then
      require('minuet.virtualtext').action.dismiss()
    end
  end, { desc = 'Minuet (IA completions) toggle' })
end

return M
