-- Configuraciones para netrw (el explorador nativo)
vim.g.netrw_banner = 0        -- Ocultar el anuncio de ayuda arriba
vim.g.netrw_liststyle = 3     -- Vista de árbol (Tree style)
vim.g.netrw_browse_split = 4  -- Abrir archivos en la ventana anterior
vim.g.netrw_altv = 1          -- Abrir divisiones a la derecha
vim.g.netrw_winsize = 25      -- Ancho predeterminado del 25%
vim.g.netrw_aleft = 1          -- Forzar que el explorador se abra a la izquierda


if vim.fn.has('wsl') == 1 then
  vim.g.clipboard = {
    name = 'WslClipboard',
    copy = {
      ['+'] = 'clip.exe',
      ['*'] = 'clip.exe',
    },
    paste = {
      ['+'] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
      ['*'] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
    },
    cache_enabled = 0,
  }
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

vim.opt.diffopt:append("vertical")
vim.opt.diffopt:append("algorithm:histogram")
vim.opt.diffopt:append("indent-heuristic")
