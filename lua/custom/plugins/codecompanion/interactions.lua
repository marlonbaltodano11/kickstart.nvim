-- Interacciones de CodeCompanion (configuración moderna)
-- El chat usa OpenCode como agente por defecto mediante ACP (Agent Client Protocol).
-- Los adaptadores HTTP siguen disponibles para inline/cmd.

return {
  chat = {
    -- OpenCode actúa como agente ACP: aporta sus propias herramientas, sesiones y permisos.
    adapter = 'opencode',
    tools = {
      -- Solo aplica cuando el chat usa un adaptador HTTP (los ACP usan sus propias tools).
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
  -- :CodeCompanionCLI abre el TUI de OpenCode dentro de Neovim.
  cli = {
    agent = 'opencode',
    agents = {
      opencode = {
        cmd = 'opencode',
        args = {},
        description = 'OpenCode CLI',
        provider = 'terminal',
      },
    },
    opts = {
      -- auto_insert = true,
      reload = true,
    },
  },
}
