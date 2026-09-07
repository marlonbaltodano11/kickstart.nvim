-- Integración con el portapapeles en WSL (Optimizado)
if vim.fn.has('wsl') == 1 then
  -- Si win32yank.exe está disponible en el PATH (recomendado por rendimiento)
  if vim.fn.executable('win32yank.exe') == 1 then
    vim.g.clipboard = {
      name = 'win32yank-wsl',
      copy = {
        ['+'] = 'win32yank.exe -i --crlf',
        ['*'] = 'win32yank.exe -i --crlf',
      },
      paste = {
        ['+'] = 'win32yank.exe -o --lf',
        ['*'] = 'win32yank.exe -o --lf',
      },
      cache_enabled = 0,
    }
  else
    -- Fallback usando clip.exe y powershell optimizado (-NoProfile)
    vim.g.clipboard = {
      name = 'WslClipboard',
      copy = {
        ['+'] = 'clip.exe',
        ['*'] = 'clip.exe',
      },
      paste = {
        ['+'] = 'powershell.exe -NoProfile -NonInteractive -command [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
        ['*'] = 'powershell.exe -NoProfile -NonInteractive -command [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
      },
      cache_enabled = 0,
    }
  end
end

-- Modelines execute commands/options found near the beginning or end of files.
-- Keep them disabled so generated or externally modified text cannot change the
-- editor state (and malformed CRLF/modeline text cannot trigger E488).
vim.opt.modeline = false
vim.opt.modelines = 0
vim.opt.modelineexpr = false

-- El plegado se mantiene nativo; no usar Treesitter globalmente para folds.
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true

vim.opt.diffopt:append {
  'vertical',
  'algorithm:histogram',
  'indent-heuristic',
}
