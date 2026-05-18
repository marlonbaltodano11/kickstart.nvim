-- Configuraciones para netrw (el explorador nativo)
vim.g.netrw_banner = 0        -- Ocultar el anuncio de ayuda arriba
vim.g.netrw_liststyle = 3     -- Vista de árbol (Tree style)
vim.g.netrw_browse_split = 4  -- Abrir archivos en la ventana anterior
vim.g.netrw_altv = 1          -- Abrir divisiones a la derecha
vim.g.netrw_winsize = 25      -- Ancho predeterminado del 25%
vim.g.netrw_aleft = 1          -- Forzar que el explorador se abra a la izquierda

-- Sincronizar el portapapeles de WSL con Windows
vim.opt.clipboard = "unnamedplus"

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

-- Avoid word wrap
vim.opt.wrap = false

-- Le dice a Neovim que use Treesitter para calcular dónde están los pliegues lógicos
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"

-- Le dice que no colapse todo automáticamente apenas abras el archivo
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true

vim.opt.diffopt:append("vertical")
vim.opt.diffopt:append("algorithm:histogram")
vim.opt.diffopt:append("indent-heuristic")
