return {
  -- =========================================================
  -- 1. Supermaven 主插件配置
  -- =========================================================
  {
    "supermaven-inc/supermaven-nvim",
    config = function()
      require("supermaven-nvim").setup({
        log_level = "off",

        -- [核心选项] 灰色幽灵文字 (Ghost Text) vs 下拉菜单 (CMP)
        -- false (默认): 开启类似 GitHub Copilot 的行内灰色文字提示。
        -- true: 关闭行内提示，只允许在 nvim-cmp 下拉菜单中显示 (如果你觉得行内文字很乱的话)。
        disable_inline_completion = true,

        -- 如果你开启了上面的行内提示 (Ghost Text)，
        -- 建议设置以下快捷键，避免和 TAB 键冲突
        keymaps = {
          accept_suggestion = "<C-f>", -- 推荐: 按 Ctrl+f 接受整行建议
          clear_suggestion = "<C-]>", -- 清楚当前的建议
          accept_word = "<C-j>", -- 只接受下一个单词 (部分接受)
        },

        -- 如果你不想让它屏蔽默认的 Tab 键行为，设为 false
        disable_keymaps = false,
      })
    end,
  },

  -- =========================================================
  -- 2. nvim-cmp 集成 (把 Supermaven 加入自动补全菜单)
  -- =========================================================
  {
    "hrsh7th/nvim-cmp",
    -- 使用 opts 函数动态添加源，避免覆盖你原有的 cmp 配置
    opts = function(_, opts)
      opts.sources = opts.sources or {}

      -- 将 supermaven 插入到补全源列表中
      -- 这样你打字时，AI 的建议也会出现在下拉列表里
      table.insert(opts.sources, {
        name = "supermaven",
        group_index = 2, -- 可选: 如果你想让它排在 LSP 后面，可以设置优先级
      })
    end,
  },
}
