-------------------------------------------------------------------------------------------------------
-------------------[TERMINAL INTEGRATION]------------------------
-------------------------------------------------------------------------------------------------------
local term_buf = nil
local term_win = nil

local function get_shell_command()
  if vim.fn.has('win32') == 1 then
    return { 'C:\\PROGRA~1\\Git\\bin\\bash.exe', '--login', '-i' }
  end
  return { vim.o.shell }
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
      vim.wo[term_win].signcolumn = 'no'
    end
    vim.cmd('startinsert')
  end
end

-- Atajos para Terminal
vim.keymap.set('n', '<leader>`', toggle_terminal, { desc = 'Toggle Terminal' })
vim.keymap.set('t', '<leader>`', function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-\\><C-n>', true, true, true), 'n', false)
  vim.schedule(toggle_terminal)
end, { desc = 'Toggle Terminal' })

-------------------------------------------------------------------------------------------------------
-------------------[GENERAL & NAVIGATION KEYMAPS]------------------------
-------------------------------------------------------------------------------------------------------
-- Abrir menú de Code Actions
vim.keymap.set({ 'n', 'v' }, '<leader>.', vim.lsp.buf.code_action, { desc = 'Code Action' })

-- Scroll horizontal con Alt + Rueda del ratón
vim.keymap.set({ 'n', 'v' }, '<A-ScrollWheelUp>', '5zh', { desc = 'Scroll horizontal a la izquierda' })
vim.keymap.set({ 'n', 'v' }, '<A-ScrollWheelDown>', '5zl', { desc = 'Scroll horizontal a la derecha' })

-- Mover la línea actual con Alt + Flechas
vim.keymap.set('n', '<A-Up>', '<cmd>m .-2<CR>==', { desc = 'Mover línea hacia arriba' })
vim.keymap.set('n', '<A-Down>', '<cmd>m .+1<CR>==', { desc = 'Mover línea hacia abajo' })

-- Mover un bloque de código seleccionado con Alt + Flechas (Modo Visual)
vim.keymap.set('v', '<A-Up>', ":m '<-2<CR>gv=gv", { desc = 'Mover bloque hacia arriba' })
vim.keymap.set('v', '<A-Down>', ":m '>+1<CR>gv=gv", { desc = 'Mover bloque hacia abajo' })

-- Yank the diagnostic under the cursor
vim.keymap.set('n', '<leader>yd', function()
  local diagnostics = vim.diagnostic.get(0, {
    lnum = vim.api.nvim_win_get_cursor(0)[1] - 1,
  })

  if #diagnostics == 0 then
    vim.notify('No diagnostics found under cursor', vim.log.levels.INFO)
    return
  end

  local messages = {}
  for _, diag in ipairs(diagnostics) do
    table.insert(messages, diag.message)
  end

  local full_message = table.concat(messages, '\n---\n')
  vim.fn.setreg('+', full_message)
  vim.notify('Copied ' .. #diagnostics .. ' diagnostic(s) to clipboard', vim.log.levels.INFO)
end, { desc = '[Y]ank Diagnostic' })

-- Copiar ruta absoluta del archivo actual
vim.keymap.set('n', '<leader>yp', function()
  local path = vim.fn.expand('%:p')
  vim.fn.setreg('+', path)
  vim.notify('Copied absolute path: ' .. path, vim.log.levels.INFO)
end, { desc = '[Y]ank Absolute [P]ath' })

-- Copiar ruta relativa del archivo actual
vim.keymap.set('n', '<leader>yr', function()
  local path = vim.fn.expand('%')
  vim.fn.setreg('+', path)
  vim.notify('Copied relative path: ' .. path, vim.log.levels.INFO)
end, { desc = '[Y]ank [R]elative Path' })

-- Better indentation helper
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')

-- Jump to the NEXT ERROR
vim.keymap.set('n', ']e', function()
  vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR })
end, { desc = 'Jump to next error' })

-- Jump to the PREVIOUS ERROR
vim.keymap.set('n', '[e', function()
  vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR })
end, { desc = 'Jump to previous error' })

-- C# plugin mappings are defined with the EasyDotnet and Neotest setup.
-------------------------------------------------------------------------------------------------------
-------------------[DEBUGGING KEYMAPS SECTION]------------------------
-------------------------------------------------------------------------------------------------------
vim.keymap.set('n', '<F5>', function() require('dap').continue() end, { desc = 'Start/Continue Debugging' })
vim.keymap.set('n', '<F9>', function() require('dap').step_into() end, { desc = 'Step Into' })
vim.keymap.set('n', '<F10>', function() require('dap').step_over() end, { desc = 'Step Over' })
vim.keymap.set('n', '<F12>', function() require('dap').step_out() end, { desc = 'Step Out' })
vim.keymap.set('n', '<F7>', function() require('dapui').toggle() end, { desc = 'Toggle DAP UI' })

vim.keymap.set('n', '<leader>b', function() require('dap').toggle_breakpoint() end, { desc = 'Toggle breakpoint' })
vim.keymap.set('n', '<leader>B', function()
  require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))
end, { desc = 'Add conditional breakpoint' })

vim.keymap.set('n', '<leader>dq', function() require('dap').terminate() end, { desc = '[D]ebug [Q]uit' })
vim.keymap.set('n', '<leader>dr', function() require('dap').restart() end, { desc = '[D]ebug [R]estart' })
vim.keymap.set('n', '<leader>de', function() require('dap').repl.open() end, { desc = '[D]ebug R[E]PL' })
vim.keymap.set('n', '<leader>dh', function() require('dap.ui.widgets').hover() end, { desc = '[D]ebug [H]over Variables' })
vim.keymap.set('n', '<leader>ds', function()
  local widgets = require('dap.ui.widgets')
  widgets.centered_float(widgets.scopes)
end, { desc = '[D]ebug [S]copes' })
-------------------------------------------------------------------------------------------------------
-------------------[END]------------------------
-------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------
-------------------[CLIPBOARD POLICY]----------------------
-------------------------------------------------------------------------------------------------------
-- The Windows clipboard is written ONLY by explicit yanks (operator 'y'):
--   yy, yiw, y$, visual y, etc.
--
-- Deletes and cuts ('d', 'c', 'x', 's', visual d/c, ...) keep their normal
-- Vim register behavior (unnamed + numbered registers) and NEVER touch the
-- system clipboard, so pasting into other apps is not polluted by them.
--
-- Explicit register operands such as "ay / "ap / "aP are left untouched
-- and behave exactly like stock Vim.
--
-- Note: with 'clipboard' unset, Vim's "+/*" registers still talk to the
-- Windows clipboard through Neovim's provider. This autocmd mirrors every
-- implicit yank (unnamed register) into "+ so it lands in the clip.
--
-- Recursion safety: vim.fn.setreg() does NOT trigger TextYankPost.

vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('to-sys-clipboard-on-yank', { clear = true }),
  desc = 'Mirror implicit yanks (operator y) into the Windows clipboard',
  callback = function()
    local event = vim.v.event

    -- Only mirror yanks that go through the unnamed register. Explicit
    -- register copies ("ay, "zy, ...) stay in their named register only.
    if event.operator ~= 'y' then return end
    if event.regname ~= '' then return end

    -- Copy the yanked text (preserving its register type) to the system
    -- clipboard. The native Windows provider (clip.exe) writes it there.
    vim.fn.setreg('+', event.regcontents, event.regtype)
  end,
})

-- Yank method/class textobjects (C# walker registrado en mini.ai)
vim.keymap.set('n', '<leader>ym', 'yam', { remap = true, silent = true, desc = 'Yank around method' })
vim.keymap.set('n', '<leader>yi', 'yim', { remap = true, silent = true, desc = 'Yank inside method' })
vim.keymap.set('n', '<leader>yc', 'yac', { remap = true, silent = true, desc = 'Yank around class' })

-- Paste policy: `p`/`P` use the system clipboard when no register was
-- specified explicitly; `gp`/`gP` paste from the last delete/change ("1).
--
-- <expr> lets Vim's own v:register decide: an explicit register ("ap) is
-- honored as-is, while the implicit (unset) case maps to the + register.
local function clip_paste_rhs(rhs)
  return function()
    local reg = vim.v.register
    if reg == '"' or reg == '' then
      reg = '+'
    end
    return '"' .. reg .. rhs
  end
end

vim.keymap.set({ 'n', 'x' }, 'p', clip_paste_rhs 'p', { expr = true, desc = 'Paste after (clipboard if no register)' })
vim.keymap.set({ 'n', 'x' }, 'P', clip_paste_rhs 'P', { expr = true, desc = 'Paste before (clipboard if no register)' })
vim.keymap.set('n', 'Y', '"+y$', { desc = 'Yank to end of line into clipboard' })
vim.keymap.set({ 'n', 'x' }, 'gp', '"1p', { desc = 'Paste after from last delete/change' })
vim.keymap.set({ 'n', 'x' }, 'gP', '"1P', { desc = 'Paste before from last delete/change' })
