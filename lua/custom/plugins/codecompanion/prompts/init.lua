-- Prompt Library de CodeCompanion
-- Recolecta y combina todos los prompts modulares

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
      skill_spec.opts = vim.tbl_deep_extend('force', skill_spec.opts or {}, { is_slash_cmd = true })
      M[name] = skill_spec
    end
  end
end

return M