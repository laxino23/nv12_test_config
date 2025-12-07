local M = {}

function M.setup()
  -- 1. Install Plugins / 安装插件
  vim.pack.add({
    -- Mini Modules
    { src = "https://github.com/echasnovski/mini.icons" },
    { src = "https://github.com/echasnovski/mini.ai" },
    { src = "https://github.com/echasnovski/mini.surround" },
    { src = "https://github.com/echasnovski/mini.splitjoin" },
    { src = "https://github.com/echasnovski/mini.trailspace" },
    { src = "https://github.com/echasnovski/mini.files" },
    { src = "https://github.com/echasnovski/mini.clue" },

    -- Navigation & Editing
    { src = "https://github.com/folke/flash.nvim" },
    { src = "https://github.com/windwp/nvim-autopairs" },
    { src = "https://github.com/max397574/better-escape.nvim" },
    { src = "https://github.com/folke/ts-comments.nvim" },
    { src = "https://github.com/windwp/nvim-ts-autotag" },
    { src = "https://github.com/jake-stewart/multicursor.nvim" },

    -- UI & Visuals
    { src = "https://github.com/nvim-tree/nvim-web-devicons" },
    { src = "https://github.com/gen740/SmoothCursor.nvim" },
    { src = "https://github.com/mcauley-penney/visual-whitespace.nvim" },
    { src = "https://github.com/lukas-reineke/virt-column.nvim" },
    { src = "https://github.com/NStefan002/screenkey.nvim" },
    { src = "https://github.com/arnamak/stay-centered.nvim" },
    { src = "https://github.com/sphamba/smear-cursor.nvim" },

    -- Session
    { src = "https://github.com/folke/persistence.nvim" },
  })

  -- 2. Load Modules / 加载模块
  require("plugins.extras.ui") -- Icons, Clue, Cursors
  require("plugins.extras.files") -- Mini.files
  require("plugins.extras.editing") -- AI, Pairs, Surround
  require("plugins.extras.navigation") -- Flash, Escape
  require("plugins.extras.session") -- Persistence
end

M.setup()

return M
