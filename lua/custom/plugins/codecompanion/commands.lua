-- Comandos personalizados de CodeCompanion
-- Funcionalidad: "Compactar" el chat. Genera un resumen de la conversación,
-- limpia el historial y lo reinyecta en contexto para no gastar tokens innecesarios.
--
-- Reutiliza la compactación integrada de CodeCompanion (más robusta que reimplementarla):
--   require("codecompanion.interactions.chat.context_management.compaction").compact(chat, opts)

local M = {}

---Compactar el chat actual (resumir y limpiar historial en contexto)
---@param chat? CodeCompanion.Chat
function M.compact(chat)
  if not chat then
    vim.notify('CodeCompanion: [compact] No hay chat activo', vim.log.levels.WARN)
    return
  end

  local ok, compaction = pcall(
    require,
    'codecompanion.interactions.chat.context_management.compaction'
  )
  if not ok then
    vim.notify('CodeCompanion: [compact] No se pudo cargar el módulo de compactación', vim.log.levels.ERROR)
    return
  end

  -- min_token_savings = 0: comprime siempre, sin importar cuántos tokens se ahorren
  compaction.compact(chat, { min_token_savings = 0 })
end

return M
