local git_bash = 'C:\\PROGRA~1\\Git\\bin\\bash.exe'

vim.api.nvim_create_user_command('Bash', function()

  vim.fn.jobstart({
    git_bash,
    '--login',
    '-i',
  }, { term = true })

  vim.cmd 'startinsert'

end, {})
