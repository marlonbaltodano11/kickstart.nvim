-- Prompt Library de CodeCompanion
-- Recolecta y combina todos los prompts modulares

local M = {}

local prompts_files = {
  'custom.plugins.codecompanion.prompts.commit',
  'custom.plugins.codecompanion.prompts.pr',
}

for _, modpath in ipairs(prompts_files) do
  local ok, result = pcall(require, modpath)
  if ok and result then
    for name, prompt_spec in pairs(result) do
      M[name] = prompt_spec
    end
  end
end

return M