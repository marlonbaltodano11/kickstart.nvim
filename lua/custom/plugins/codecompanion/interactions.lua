-- Interacciones de CodeCompanion (configuración moderna)
-- Aquí se define el adaptador y los keymaps por interacción (chat, inline, cli)

return {
  chat = {
    adapter = 'openrouter',
    tools = {
      -- Make YOLO mode include shell commands. Outside YOLO mode, commands
      -- continue to require approval as usual.
      ['run_command'] = {
        opts = {
          allowed_in_yolo_mode = true,
        },
      },
    },
    keymaps = {
      -- Compactar el chat: genera un resumen y limpia el historial, ahorrando tokens
      compact = {
        modes = { n = 'gC' },
        index = 23,
        callback = require('custom.plugins.codecompanion.commands').compact,
        description = 'Compact the chat (summarize and clear history)',
      },
    },
  },
  inline = {
    adapter = 'openrouter',
  },
}