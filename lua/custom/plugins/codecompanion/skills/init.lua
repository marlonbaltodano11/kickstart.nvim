-- Skills de CodeCompanion
-- Recolecta y combina todos los skills modulares

local M = {}

local skill_files = {
  'custom.plugins.codecompanion.skills.review',
  'custom.plugins.codecompanion.skills.refactor',
  'custom.plugins.codecompanion.skills.test',
  'custom.plugins.codecompanion.skills.architect',
}

for _, modpath in ipairs(skill_files) do
  local ok, result = pcall(require, modpath)
  if ok and result then
    for name, skill_spec in pairs(result) do
      M[name] = skill_spec
    end
  end
end

return M