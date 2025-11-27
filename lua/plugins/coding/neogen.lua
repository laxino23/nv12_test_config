return {
  "danymat/neogen",
  -- 只有在使用命令 :Neogen 或按下快捷键时才加载
  cmd = "Neogen",
  keys = {
    {
      "<leader>cn", -- mnemonic: [C]ode [N]eogen
      function()
        require("neogen").generate()
      end,
      desc = "Generate Annotations (生成函数/类文档)",
    },
  },
  opts = {
    enabled = true,

    -- [重要] 很多用户在这里遇到坑
    -- 这里的引擎决定了生成的注释是否支持 "Tab 跳转" (像写代码片段一样跳到下一个参数)
    -- 如果你安装了 'L3MON4D3/LuaSnip'，这里填 "luasnip"。
    -- 如果你只用 Neovim 0.10+ 原生片段 (无 LuaSnip)，可以试着填 "nvim"。
    snippet_engine = "luasnip",

    -- 生成注释后，自动进入插入模式并选中第一个参数的描述
    -- 这样你可以直接开始打字，不需要手动移动光标
    input_after_comment = true,
  },
}
