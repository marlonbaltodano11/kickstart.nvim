-- Alternar el explorador de archivos Neo-tree
vim.keymap.set('n', '<leader>e', '<cmd>Neotree toggle<CR>', { desc = 'Toggle Explorer' })

-- Open git bash terminal
local term_buf = nil
local term_win = nil

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

      local git_bash = 'C:\\PROGRA~1\\Git\\bin\\bash.exe'
      vim.fn.jobstart({
        git_bash,
        '--login',
        '-i'
      }, { term = true })

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
