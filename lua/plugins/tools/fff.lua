return {
  "dmtrKovalenko/fff.nvim",

  -- [构建步骤] 重要：因为核心是用 Rust 写的，第一次安装时需要下载或编译二进制文件
  build = function()
    require("fff.download").download_or_build_binary()
  end,

  opts = {
    -- 搜索框左侧的提示符 (这里用了一只鹅 🪿)
    prompt = "🪿 ",

    -- [快捷键] 在搜索窗口打开时的操作按键
    keymaps = {
      close = "<Esc>", -- 关闭窗口
      select = "<CR>", -- 选中并打开文件 (回车键)
      -- 向上移动光标 (支持方向键, Ctrl+p, Ctrl+k)
      move_up = { "<Up>", "<C-p>", "<C-k>" },
      -- 向下移动光标 (支持方向键, Ctrl+n, Ctrl+j)
      move_down = { "<Down>", "<C-n>", "<C-j>" },
    },

    -- [高亮] 匹配到的字符用什么颜色显示
    hl = {
      matched = "Search", -- 使用 Neovim 默认的搜索高亮色
    },

    -- [调试] 通常你可以关掉它，除非你想看打分算法
    debug = {
      enabled = true, -- 开启调试模式
      show_scores = true, -- 显示每个文件的匹配分数 (用于排查为什么这个文件排在前面)
    },
  },

  -- lazy = false 表示启动 Neovim 时立即加载
  -- (通常建议改为 lazy = true 并配合 keys 使用，以加快启动速度)
  lazy = false,

  keys = {
    {
      "<leader><space>",
      function()
        require("fff").find_files()
      end,
      desc = "FFFind files (快速查找文件)",
    },
  },
}
