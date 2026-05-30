local git_bash = 'C:\\PROGRA~1\\Git\\bin\\bash.exe'

vim.api.nvim_create_user_command('Bash', function()

  vim.fn.jobstart({
    git_bash,
    '--login',
    '-i',
  }, { term = true })

  vim.cmd 'startinsert'

end, {})

vim.api.nvim_create_user_command('SqlDB2', function()
  require('conform').formatters.sql_formatter = {
    args = { "-l", "db2i" }
  }
  print("SQL Formatter switched to: DB2 (AS400)")
end, { desc = "Switch SQL formatter dialect to DB2" })

vim.api.nvim_create_user_command('SqlPostgres', function()
  require('conform').formatters.sql_formatter = {
    args = { "-l", "postgresql" }
  }
  print("SQL Formatter switched to: PostgreSQL")
end, { desc = "Switch SQL formatter dialect to PostgreSQL" })

