-- Reglas (rules) de CodeCompanion
-- Configura comportamientos base del asistente

return {
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
}