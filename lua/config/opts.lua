local o = vim.opt
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- =============================================================================
--  1. UI & Visuals
-- =============================================================================
o.number = true -- Show line numbers
o.relativenumber = true -- Relative line numbers (helpful for jumping)
o.cursorline = true -- Highlight the current line
o.signcolumn = "yes" -- Always show the sign column (prevents text shifting)
o.termguicolors = true -- Enable 24-bit RGB color in the TUI
o.sidescrolloff = 8 -- Columns of context
o.wrap = true -- Disable line wrapping (personal preference, usually better for code)
o.textwidth = 80
o.colorcolumn = "80"
o.scrolloff = 8 -- Minimal line from the bottom of the screen
o.whichwrap:append("<,>,[,],h,l")
-- =============================================================================
--  2. Indentation (2 spaces standard for Lua/Web, 4 for Python usually)
-- =============================================================================
o.expandtab = true -- Use spaces instead of tabs
o.tabstop = 4 -- Number of spaces tabs count for
o.shiftwidth = 0 -- Size of an indent
o.softtabstop = 4 -- Insert 2 spaces for a tab
o.smartindent = true -- Insert indents automatically

-- =============================================================================
--  3. Search & Replace
-- =============================================================================
o.ignorecase = true -- Ignore case
o.smartcase = true -- ...unless it contains a capital letter
o.inccommand = "split" -- Preview substitutions live (e.g., :%s/foo/bar/)

-- =============================================================================
--  4. System & Performance
-- =============================================================================
o.clipboard = "unnamedplus" -- Sync with system clipboard (requires xclip/wl-clipboard)
o.updatetime = 250 -- Save swap file and trigger CursorHold faster
o.timeoutlen = 300 -- Decrease time to wait for a mapped sequence to complete
o.swapfile = false -- Disable swap files (usually annoying, git is better)
o.backup = false -- Avoid generate extra backup files
o.encoding = "utf-8" -- Internal encoding for vim
o.fileencoding = "utf-8"
-- =============================================================================
--  5. Window Splitting
-- =============================================================================
o.splitright = true -- Put new windows right of current
o.splitbelow = true -- Put new windows below current

-- =============================================================================
--  6. History and Undos
-- =============================================================================
o.undofile = true -- Save undo history (persistent undo across restarts)
o.undolevels = 10000 -- Max history of undos
o.undoreload = 10000 -- Max history of redos
o.history = 1000 -- :command history numbers

-- =============================================================================
--  7. Others
-- =============================================================================
o.completeopt = { "menu", "menuone", "noselect" } -- Completion
