return {
  "kevinhwang91/nvim-ufo",
  event = { "InsertEnter", "BufRead", "BufNewFile" },
  dependencies = { "kevinhwang91/promise-async" },

  -- === 快捷键配置 ===
  -- 这里的快捷键复用了 Vim 原生的折叠键位，但调用了 ufo 的功能
  keys = {
    {
      "zR",
      function()
        require("ufo").openAllFolds()
      end,
      desc = "(Open all folds)",
    },
    {
      "zM",
      function()
        require("ufo").closeAllFolds()
      end,
      desc = "(Close all folds)",
    },
    {
      "zr",
      function()
        require("ufo").openFoldsExceptKinds()
      end,
      desc = "(Fold less)",
    },
    {
      "zm",
      function()
        require("ufo").closeFoldsWith()
      end,
      desc = "(Fold more)",
    },
    {
      "zp",
      function()
        require("ufo").peekFoldedLinesUnderCursor()
      end,
      desc = "(Peek fold)",
    },
  },

  -- === 插件核心配置 (opts) ===
  opts = {
    -- 预览窗口配置 (按 zp 时出现的那个悬浮窗)
    preview = {
      mappings = {
        scrollB = "<C-B>", -- 向上滚动预览窗口
        scrollF = "<C-F>", -- 向下滚动预览窗口
        scrollU = "<C-U>", -- 向上半屏滚动
        scrollD = "<C-D>", -- 向下半屏滚动
      },
    },

    -- [核心逻辑] 提供者选择器：决定用什么方式来计算折叠范围
    -- ufo 支持 LSP、Treesitter 和 Indent (缩进) 三种方式
    provider_selector = function(_, filetype, buftype)
      -- 定义一个处理回退的辅助函数
      -- 如果首选方法失败 (抛出 UfoFallbackException)，则尝试备选方案
      local function handleFallbackException(bufnr, err, providerName)
        if type(err) == "string" and err:match("UfoFallbackException") then
          return require("ufo").getFolds(bufnr, providerName)
        else
          return require("promise").reject(err)
        end
      end

      -- 如果是特殊文件类型（空或非文件），直接使用 'indent' (缩进) 折叠
      -- 否则使用链式策略：
      return (filetype == "" or buftype == "nofile") and "indent"
        or function(bufnr)
          -- 1. 第一优先级：尝试使用 LSP (语言服务器) 计算折叠
          return require("ufo")
            .getFolds(bufnr, "lsp")
            -- 2. 如果 LSP 失败，捕获错误并尝试使用 Treesitter
            :catch(
              function(err)
                return handleFallbackException(bufnr, err, "treesitter")
              end
            )
            -- 3. 如果 Treesitter 也失败，最后尝试使用 Indent (纯缩进)
            :catch(
              function(err)
                return handleFallbackException(bufnr, err, "indent")
              end
            )
        end
    end,
  },

  -- === 初始化配置 ===
  config = function(_, opts)
    -- 设置 Vim 原生的折叠选项，这是 ufo 正常工作所必须的

    -- foldcolumn: 在行号左侧显示折叠状态栏
    -- '0' 是不显示，'1' 显示一列宽度的指示器
    vim.o.foldcolumn = "1"

    -- foldlevel & foldlevelstart: 起始折叠层级
    -- 必须设置为大数值 (如 99)，否则打开文件时代码会自动折叠起来
    -- ufo 需要接管折叠逻辑，所以这里先告诉 Vim "全打开"
    vim.o.foldlevel = 99
    vim.o.foldlevelstart = 99

    -- 开启折叠功能
    vim.o.foldenable = true

    -- 启动插件
    require("ufo").setup(opts)
  end,
}
