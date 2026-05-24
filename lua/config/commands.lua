local git_bash = 'C:\\PROGRA~1\\Git\\bin\\bash.exe'

vim.api.nvim_create_user_command('Bash', function()

  vim.fn.jobstart({
    git_bash,
    '--login',
    '-i',
  }, { term = true })

  vim.cmd 'startinsert'

end, {})

local function find_startup_project()
  local cwd = vim.fn.getcwd()

  local csproj_files = vim.fn.glob(cwd .. "/**/*.csproj", true, true)

  local candidates = {}

  for _, file in ipairs(csproj_files) do
    local name = vim.fn.fnamemodify(file, ":t")

    -- filter out tests and libs
    if
      not name:lower():match("test")
      and not name:lower():match("spec")
      and not name:lower():match("unit")
    then
      table.insert(candidates, file)
    end
  end

  -- priority: Api projects first
  table.sort(candidates, function(a, b)
    local a_score = a:lower():match("api") and 1 or 0
    local b_score = b:lower():match("api") and 1 or 0
    return a_score > b_score
  end)

  if #candidates == 0 then
    error("No startup project (.csproj) found")
  end

  return candidates[1]
end

vim.keymap.set("n", "<leader>cr", function()
  local csproj = find_startup_project()
  vim.cmd("split | terminal dotnet run --project " .. csproj)
end, { desc = "[C]# Run startup project" })
