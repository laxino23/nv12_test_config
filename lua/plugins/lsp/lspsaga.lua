return {
  "nvimdev/lspsaga.nvim",
  event = "LspAttach",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("lspsaga").setup({

      -- === 悬停文档 (Hover) ===
      hover = {
        max_width = 0.6,
        open_link = "gx",
        open_browser = "!chrome",
      },

      -- === 诊断信息 (Diagnostic) ===
      diagnostic = {
        show_code_action = true,
        show_source = true,
        jump_num_shortcut = true,
        max_width = 0.7,
        text_hl_follow = true,
        border_follow = true,
        -- 使用你的诊断图标
        keys = {
          exec_action = "o",
          quit = "q",
          go_action = "g",
        },
      },

      -- === 代码操作 (Code Action) ===
      code_action = {
        num_shortcut = true,
        show_server_name = true,
        extend_gitsigns = true,
        keys = {
          quit = "q",
          exec = "<CR>",
        },
      },

      -- === 灯泡提示 ===
      lightbulb = {
        enable = true,
        enable_in_insert = false,
        sign = true,
        virtual_text = false,
      },

      -- === 查找引用/定义 (Finder) ===
      finder = {
        max_height = 0.5,
        min_width = 30,
        force_max_height = false,
        keys = {
          jump_to = "p",
          expand_or_jump = "o",
          vsplit = "s",
          split = "i",
          tabe = "t",
          quit = { "q", "<ESC>" },
        },
      },

      -- === 定义预览 ===
      definition = {
        edit = "<C-c>o",
        vsplit = "<C-c>v",
        split = "<C-c>i",
        tabe = "<C-c>t",
        quit = "q",
      },

      -- === 重命名 ===
      rename = {
        quit = "<C-c>",
        exec = "<CR>",
        mark = "x",
        confirm = "<CR>",
        in_select = true,
      },

      -- === 大纲视图 (Outline) ===
      outline = {
        win_position = "right",
        win_with = "",
        win_width = 30,
        show_detail = true,
        auto_preview = true,
        auto_refresh = true,
        auto_close = true,
        keys = {
          expand_or_jump = "o",
          quit = "q",
        },
      },

      -- === 面包屑导航 ===
      symbol_in_winbar = {
        enable = true,
        ignore_patterns = {},
        hide_keyword = true,
        show_file = true,
        folder_level = 2,
        color_mode = true,
      },
    })
  end,
  keys = {
    { "<leader>lr", "<cmd>Lspsaga rename<CR>", desc = "Rename Symbol" },
    { "<leader>lc", "<cmd>Lspsaga code_action<CR>", desc = "Code Action" },
    { "<leader>ld", "<cmd>Lspsaga peek_definition<CR>", desc = "Peek Definition" },
    { "<Leader>lh", "<cmd>Lspsaga hover_doc<CR>", desc = "Hover Documentation" },
    { "<Leader>lR", "<cmd>Lspsaga finder<CR>", desc = "LSP Finder" },
    {
      "<Leader>ln",
      "<cmd>Lspsaga diagnostic_jump_next<CR>",
      desc = "Next Diagnostic",
    },
    {
      "<Leader>lp",
      "<cmd>Lspsaga diagnostic_jump_prev<CR>",
      desc = "Prev Diagnostic",
    },
  },
}
