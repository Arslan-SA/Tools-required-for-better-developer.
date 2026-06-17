local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Tabs and indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true

-- Search
opt.ignorecase = true
opt.smartcase = true

-- Scrolling
opt.scrolloff = 8

-- Clipboard
opt.clipboard = "unnamedplus"

-- Appearance
opt.cursorline = true
opt.termguicolors = true
opt.wrap = false

-- Split behavior
opt.splitbelow = true
opt.splitright = true

-- Mouse support
opt.mouse = "a"