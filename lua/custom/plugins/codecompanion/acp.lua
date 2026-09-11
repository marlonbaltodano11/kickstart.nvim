-- Adaptadores ACP de CodeCompanion (agentes vía Agent Client Protocol)
-- OpenCode actúa como agente por defecto en el chat.

local M = {}

function M.opencode()
  return require('codecompanion.adapters').extend('opencode', {
    defaults = {
      session_config_options = {
        model = 'opencode-go/deepseek-v4-flash',
        mode = 'build',
      },
    },
  })
end

return M
