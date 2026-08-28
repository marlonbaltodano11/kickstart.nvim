-- Reglas (rules) de CodeCompanion
-- Configura comportamientos base del asistente

local rules = {}
local personal_rules_path = vim.fn.expand '~/ai-rules.md'

if vim.fn.filereadable(personal_rules_path) == 1 then
  rules[#rules + 1] = {
    path = personal_rules_path,
    parser = 'codecompanion',
  }
end

return {
  default = {
    description = 'Base rules for assistant behavior',
    prompt = 'Base rules defining the default behavior of the assistant.',
    files = rules,
  },
}