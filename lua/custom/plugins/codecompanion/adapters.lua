-- Adaptadores de CodeCompanion
-- Separados para fácil mantenimiento y adición de nuevos proveedores

local M = {}

function M.openrouter()
  return require('codecompanion.adapters').extend('openai_compatible', {
    name = 'openrouter',
    env = {
      api_key = os.getenv 'OPENROUTER_API_KEY',
    },
    url = 'https://openrouter.ai/api/v1/chat/completions',
    schema = {
      model = {
        default = 'deepseek/deepseek-v4-flash',
        choices = {
          'deepseek/deepseek-v4-flash',
          'deepseek/deepseek-v4-flash-0731',
          'deepseek/deepseek-v4-pro-0813',
          'openai/gpt-5.6-luna',
          'openai/gpt-5.6-luna-pro',
        },
      },
    },
  })
end

function M.gemini()
  return require('codecompanion.adapters').extend('gemini', {
    name = 'gemini',
    env = {
      api_key = os.getenv 'GEMINI_API_KEY',
    },
    schema = {
      model = { default = 'gemini-3.1-flash-lite-preview' },
    },
  })
end

function M.minimax()
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
end

function M.deepseek()
  return require('codecompanion.adapters').extend('openai_compatible', {
    name = 'deepseek',
    env = {
      api_key = os.getenv 'DEEPSEEK_API_KEY',
    },
    url = 'https://api.deepseek.com/v1/chat/completions',
    schema = {
      model = {
        default = 'deepseek-v4-flash',
        choices = {
          'deepseek-v4-flash',
          'deepseek-v4-pro',
        },
      },
    },
  })
end

return M
