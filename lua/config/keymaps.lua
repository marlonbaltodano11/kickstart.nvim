-- Alternar el explorador de archivos Neo-tree
-- vim.keymap.set('n', '<leader>e', '<cmd>Neotree toggle<CR>', { desc = 'Toggle Explorer' })

-- Open git bash terminal
local term_buf = nil
local term_win = nil

local function get_shell_command()
  if vim.fn.has('win32') == 1 then
    return {
      'C:\\PROGRA~1\\Git\\bin\\bash.exe',
      '--login',
      '-i',
    }
  end

  return {
    vim.o.shell,
  }
end

local function toggle_terminal()
  if term_win and vim.api.nvim_win_is_valid(term_win) then
    vim.api.nvim_win_hide(term_win)
  else
    vim.cmd('botright 15split')
    term_win = vim.api.nvim_get_current_win()

    if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
      vim.api.nvim_win_set_buf(term_win, term_buf)
    else
      vim.cmd('enew')
      term_buf = vim.api.nvim_get_current_buf()

      vim.fn.jobstart(get_shell_command(), { term = true })

      vim.wo[term_win].number = false
      vim.wo[term_win].relativenumber = false
      vim.wo[term_win].signcolumn = "no"
    end
    vim.cmd('startinsert')
  end
end

-- Atajos
vim.keymap.set('n', '<leader>`', toggle_terminal, { desc = 'Toggle Terminal' })
vim.keymap.set('t', '<leader>`', function()
  local escape_key = vim.api.nvim_replace_termcodes('<C-\\><C-n>', true, false, true)
  vim.api.nvim_feedkeys(escape_key, 'n', false)
  toggle_terminal()
end, { desc = 'Toggle Terminal' })

-- Abrir menú de Code Actions con Alt + Enter
vim.keymap.set({ 'n', 'v' }, '<leader>.', vim.lsp.buf.code_action, { desc = 'Code Action' })

-- Scroll horizontal con Shift + Rueda del ratón
vim.keymap.set({ 'n', 'v' }, '<A-ScrollWheelUp>', '5zh', { desc = 'Scroll horizontal a la izquierda' })
vim.keymap.set({ 'n', 'v' }, '<A-ScrollWheelDown>', '5zl', { desc = 'Scroll horizontal a la derecha' })

-- Mover la línea actual con Alt + Flechas (Modo Normal)
vim.keymap.set('n', '<A-Up>', '<cmd>m .-2<CR>==', { desc = 'Mover línea hacia arriba' })
vim.keymap.set('n', '<A-Down>', '<cmd>m .+1<CR>==', { desc = 'Mover línea hacia abajo' })

-- Mover un bloque de código seleccionado con Alt + Flechas (Modo Visual)
vim.keymap.set('v', '<A-Up>', ":m '<-2<CR>gv=gv", { desc = 'Mover bloque hacia arriba' })
vim.keymap.set('v', '<A-Down>', ":m '>+1<CR>gv=gv", { desc = 'Mover bloque hacia abajo' })

-- Yank the diagnostic under the cursor
vim.keymap.set("n", "<leader>yd", function()
  local diagnostics = vim.diagnostic.get(0, {
    lnum = vim.api.nvim_win_get_cursor(0)[1] - 1,
  })

  if #diagnostics == 0 then
    print("No diagnostics found")
    return
  end

  local message = diagnostics[1].message

  vim.fn.setreg("+", message)

  print("Diagnostic copied to clipboard")
end, { desc = "[C]opy Diagnostic" })

-- Yank the absolute path of the currently open file
vim.keymap.set("n", "<leader>yp", function()
  local path = vim.fn.expand("%:p")

  vim.fn.setreg("+", path)

  print("Copied path: " .. path)
end, { desc = "[C]opy Absolute [P]ath" })

-- Yank the relative path of the currently open file
vim.keymap.set("n", "<leader>yr", function()
  local path = vim.fn.expand("%")

  vim.fn.setreg("+", path)

  print("Copied relative path: " .. path)
end, { desc = "[C]opy [R]elative Path" })

-- Better indentation helper
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')

-- Reveal currently open file in neotree
-- vim.keymap.set('n', '<leader>rf', ':Neotree action=focus reveal<CR>', { desc = '[R]eveal and [F]ocus in NeoTree' })
-- vim.keymap.set('n', '<leader>rs', ':Neotree action=show reveal<CR>', { desc = '[R]eveal and [S]how (no focus)' })

-- Jump to the NEXT ERROR
vim.keymap.set('n', ']E', function()
  vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR })
end, { desc = 'Jump to next error' })

-- Jump to the PREVIOUS ERROR
vim.keymap.set('n', '[E', function()
  vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR })
end, { desc = 'Jump to previous error' })

-- Easy Dotnet commands:
vim.keymap.set("n", "<leader>cr", "<cmd>Dotnet run profile Development<cr>", { desc = "[C]sharp [R]un" })

-- Para elegir qué proyecto correr si el automático falla:
vim.keymap.set("n", "<leader>cs", "<cmd>Dotnet select_project<cr>", { desc = "[C]sharp [S]elect Project" })

-- Build, Restore y Clean (usando el plugin es más limpio)
vim.keymap.set("n", "<leader>cb", "<cmd>Dotnet build quickfix<cr>", { desc = "[C]sharp [B]uild" })
vim.keymap.set("n", "<leader>cR", "<cmd>Dotnet restore<cr>", { desc = "[C]sharp [R]estore" })
vim.keymap.set("n", "<leader>cC", "<cmd>Dotnet clean<cr>", { desc = "[C]sharp [C]lean" })

-- Test (Algo que tu script no hacía pero easy-Dotnet sí)
vim.keymap.set("n", "<leader>cat", "<cmd>Dotnet test<cr>", { desc = "[C]sharp [T]est" })

vim.keymap.set("n", "<leader>ct", "<cmd>Dotnet testrunner<CR>", { desc = "[C]sharp [T]est Runner" })

vim.keymap.set({ 'n', 'v', 't' }, "<leader>cT", "<cmd>Dotnet terminal toggle<CR>", { desc = "[C]sharp [T]erminal Toggle" })

-------------------------------------------------------------------------------------------------------
-------------------[DEBUGGING KEYMAPS SECTION]------------------------
-------------------------------------------------------------------------------------------------------
vim.keymap.set('n', '<F5>', function()
  require('dap').continue()
end, { desc = 'Start/Continue Debugging' })

vim.keymap.set('n', '<F9>', function()
  require('dap').step_into()
end, { desc = 'Step Into' })

vim.keymap.set('n', '<F10>', function()
  require('dap').step_over()
end, { desc = 'Step Over' })

vim.keymap.set('n', '<F12>', function()
  require('dap').step_out()
end, { desc = 'Step Out' })

vim.keymap.set('n', '<leader>b', function()
  require('dap').toggle_breakpoint()
end, { desc = "Toggle breakpoint" })

vim.keymap.set("n", "<leader>B", function()
  require('dap').set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "Add conditional breakpoint" })

vim.keymap.set("n", "<leader>dq", function()
  require("dap").terminate()
end, { desc = "[D]ebug [Q]uit" })

vim.keymap.set("n", "<leader>dr", function()
  require("dap").restart()
end, { desc = "[D]ebug [R]estart" })

vim.keymap.set("n", "<leader>de", function()
  require("dap").repl.open()
end, { desc = "[D]ebug R[E]PL" })

vim.keymap.set("n", "<leader>dh", function()
  require("dap.ui.widgets").hover()
end, { desc = "[D]ebug [H]over Variables" })

vim.keymap.set("n", "<leader>ds", function()
  local widgets = require("dap.ui.widgets")
  widgets.centered_float(widgets.scopes)
end, { desc = "[D]ebug [S]copes" })
-------------------------------------------------------------------------------------------------------
-------------------[END]------------------------
-------------------------------------------------------------------------------------------------------
