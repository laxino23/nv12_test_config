local ui = require("config.ui")

return {
  {
    "ibhagwan/fzf-lua",
    cmd = "FzfLua", -- 只有在运行 :FzfLua 命令时才加载插件 (懒加载)
    dependencies = { "nvim-mini/mini.icons" }, -- 依赖图标库
    opts = {
      -- 使用预设的配置方案
      "border-fused", -- 边框风格：融合风格
      "hide", -- 默认隐藏一些不必要的元素

      -- fzf 内部颜色配置
      fzf_colors = {
        true, -- 继承 Neovim 的配色
        -- 匹配到的字符高亮：使用 SnacksPickerMatch 高亮组，加粗、斜体、下划线
        ["hl+"] = { "fg", "SnacksPickerMatch", "bold", "italic", "underline" },
      },

      -- 传递给 fzf 二进制文件的原生参数
      fzf_opts = {
        ["--no-scrollbar"] = true, -- 隐藏滚动条
      },

      -- === 默认窗口配置 ===
      -- 如果快捷键里没有指定 winopts，就会用这一套默认的
      winopts = {
        height = 0.9, -- 窗口高度占比 90%
        width = 1, -- 窗口宽度占比 100% (全宽)
        row = 1, -- 窗口位置：底部 (1 表示 bottom)
        col = 0, -- 窗口位置：左侧
        border = "rounded", -- 圆角边框
        backdrop = 100, -- 背景遮罩透明度 (100 表示完全变暗/不透明，或者非常暗)

        -- 预览窗口配置
        preview = {
          border = "rounded",
          wrap = true, -- 自动换行
          hidden = false, -- 默认显示预览
          layout = "vertical", -- 垂直布局 (预览在上方或下方)
          vertical = "up:55%", -- 预览窗口在上方，占据 55% 的高度
        },
      },

      -- === 文件查找配置 ===
      files = {
        multiprocess = true, -- 启用多进程搜索 (更快)
        git_icons = true, -- 显示 Git 状态图标
        file_icons = true, -- 显示文件图标
        color_icons = true, -- 图标彩色
        -- 路径格式化：文件名优先
        -- 显示为: config.lua (lua/core/) 而不是 lua/core/config.lua
        -- 这对于在很深的目录中查找文件非常有用
        formatter = "path.filename_first",
      },

      -- 历史文件 (Oldfiles) 配置
      oldfiles = {
        formatter = "path.filename_first",
      },

      -- 缓冲区 (Buffers) 配置
      buffers = {
        formatter = "path.filename_first",
      },

      -- LSP 符号配置
      lsp = {
        symbols = {
          -- 使用 core.ui 中定义的 mini_kind_icons 图标
          symbol_icons = ui.icons.mini_kind_icons,
        },
      },

      -- 诊断信息配置
      diagnostics = {
        cwd_only = true, -- 只显示当前工作目录下的报错
        file_icons = true,
        git_icons = true,
      },
    },

    -- === 快捷键映射 ===
    keys = {
      -- 1. 缓冲区查找
      {
        "<leader>fb",
        function()
          require("fzf-lua").buffers({
            cwd_only = true, -- 只列出当前项目目录下的 buffer
          })
        end,
        desc = "Fzf buffers",
      },

      -- 2. 配色方案切换 (带预览，非常实用)
      {
        "<leader>fc",
        function()
          require("fzf-lua").colorschemes()
        end,
        desc = "Fzf colorschemes",
      },

      -- 3. 全局搜索 (Global)
      -- 注意：这里使用了 core.ui 中定义的 Ivy 布局 (底部面板风格)
      {
        "<leader>fg",
        function()
          require("fzf-lua").global({
            winopts = ui.fzf.ivy.winopts,
          })
        end,
        desc = "Global",
      },

      -- 4. 自动命令 (Autocmds)
      -- 注意：这里使用了 core.ui 中定义的 Dropdown 布局 (下拉框风格)
      {
        "<leader>fa",
        function()
          require("fzf-lua").autocmds({ winopts = ui.fzf.dropdown.winopts })
        end,
        desc = "Fzf Autocmds",
      },

      -- 5. Location List
      {
        "<leader>fl",
        function()
          require("fzf-lua").loclist({ winopts = ui.fzf.dropdown.winopts })
        end,
        desc = "Fzf location list",
      },

      -- 6. 查看快捷键 (Keymaps)
      {
        "<leader>fk",
        function()
          require("fzf-lua").keymaps({ winopts = ui.fzf.dropdown.winopts })
        end,
        desc = "Fzf keymaps",
      },

      -- 7. 跳转列表 (Jumps)
      {
        "<leader>fj",
        function()
          require("fzf-lua").jumps({ winopts = ui.fzf.dropdown.winopts })
        end,
        desc = "Fzf jumps",
      },

      -- 8. 寄存器 (Registers) - 查看复制粘贴板历史
      {
        "<leader>fr",
        function()
          require("fzf-lua").registers({ winopts = ui.fzf.dropdown.winopts })
        end,
        desc = "Fzf registers",
      },

      -- === Git 相关功能 (强项) ===
      -- 这里的快捷键全部使用 <leader>g 开头，并且统一使用 Dropdown 布局

      {
        "<leader>gf",
        function()
          require("fzf-lua").git_files({ winopts = ui.fzf.dropdown.winopts })
        end,
        desc = "Git files", -- 查找 Git 管理的文件
      },
      {
        "<leader>gb",
        function()
          require("fzf-lua").git_branches({ winopts = ui.fzf.dropdown.winopts })
        end,
        desc = "Git branches", -- 切换 Git 分支
      },
      {
        "<leader>gc",
        function()
          require("fzf-lua").git_commits({ winopts = ui.fzf.dropdown.winopts })
        end,
        desc = "Git commits", -- 查看提交历史
      },
      {
        "<leader>gC",
        function()
          require("fzf-lua").git_bcommits({ winopts = ui.fzf.dropdown.winopts })
        end,
        desc = "Git bcommits", -- 查看【当前 buffer】的提交历史
      },
      {
        "<leader>gs",
        function()
          require("fzf-lua").git_status({ winopts = ui.fzf.dropdown.winopts })
        end,
        desc = "Git status", -- 查看 Git 状态 (变更的文件)
      },
      {
        "<leader>gd",
        function()
          require("fzf-lua").git_diff({ winopts = ui.fzf.dropdown.winopts })
        end,
        desc = "Git diff", -- 查看 Diff
      },
      {
        "<leader>gB",
        function()
          require("fzf-lua").git_blame({ winopts = ui.fzf.dropdown.winopts })
        end,
        desc = "Git blame", -- 查看每一行的作者 (Blame)
      },
      {
        "<leader>gt",
        function()
          require("fzf-lua").git_tags({ winopts = ui.fzf.dropdown.winopts })
        end,
        desc = "Git tags", -- 查找 Tag
      },
      {
        "<leader>gh",
        function()
          require("fzf-lua").git_hunks({ winopts = ui.fzf.dropdown.winopts })
        end,
        desc = "Git hunks", -- 查找当前的修改块 (Hunk)
      },
      {
        "<leader>gw",
        function()
          require("fzf-lua").git_worktrees({ winopts = ui.fzf.dropdown.winopts })
        end,
        desc = "Git worktrees", -- 管理 Worktree
      },
    },
    config = function(_, opts)
      require("fzf-lua").setup(opts)
    end,
  },
}
