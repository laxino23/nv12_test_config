return {
  "windwp/nvim-autopairs",
  event = "InsertEnter", -- 进入插入模式时加载
  -- [!] 注意：不再需要依赖 nvim-cmp
  opts = {
    check_ts = true, -- 启用 Treesitter 检查
    ts_config = {
      lua = { "string", "source" },
      javascript = { "template_string" },
      java = false,
    },

    -- [!] 防误触设置
    -- 如果光标后面是字母或点号，不自动补全右括号。
    -- 防止在 "func" 中间输入 "(" 变成 "func(|)"
    ignored_next_char = "[%w%.]",

    disable_filetype = { "TelescopePrompt", "spectre_panel", "vim", "snacks_picker_input" },

    -- [!] Fast Wrap (快速包裹)
    -- 按 <M-e> 然后按符号，快速包裹单词
    fast_wrap = {
      map = "<M-e>",
      chars = { "{", "[", "(", '"', "'" },
      pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
      offset = 0,
      end_key = "$",
      keys = "qwertyuiopzxcvbnmasdfghjkl",
      check_comma = true,
      highlight = "PmenuSel",
      highlight_grey = "LineNr",
    },
  },
  config = function(_, opts)
    local npairs = require("nvim-autopairs")
    local Rule = require("nvim-autopairs.rule")
    local cond = require("nvim-autopairs.conds")

    npairs.setup(opts)

    -- =======================================================================
    -- 自定义高级规则 (Rules)
    -- =======================================================================

    -- 1. 括号内加空格: (|) + Space -> ( | )
    npairs.add_rules({
      Rule(" ", " ")
        :with_pair(function(opts)
          local pair = opts.line:sub(opts.col - 1, opts.col)
          return vim.tbl_contains({ "()", "[]", "{}" }, pair)
        end)
        :with_move(cond.none())
        :with_cr(cond.none())
        :with_del(function(opts)
          local col = vim.api.nvim_win_get_cursor(0)[2]
          local context = opts.line:sub(col - 1, col + 2)
          return vim.tbl_contains({ "(  )", "[  ]", "{  }" }, context)
        end),
    })

    -- 2. 跳过括号内的空格: ( | ) + ) -> (  )|
    local brackets = { { "(", ")" }, { "[", "]" }, { "{", "}" } }
    for _, bracket in pairs(brackets) do
      npairs.add_rules({
        Rule(bracket[1] .. " ", " " .. bracket[2])
          :with_pair(cond.none())
          :with_move(function(opts)
            return opts.char == bracket[2]
          end)
          :with_del(cond.none())
          :use_key(bracket[2])
          :replace_map_cr(function(_)
            return "<C-c>2xi<CR><C-c>O"
          end),
      })
    end

    -- 3. 箭头函数 (JS/TS/Vue): () = > -> () => { | }
    npairs.add_rules({
      Rule(
        "%(.*%)%s*%=>$",
        " {  }",
        { "typescript", "typescriptreact", "javascript", "javascriptreact", "vue" }
      ):use_regex(true):set_end_pair_length(2),
    })

    -- 4. Python 三引号: """ -> """|"""
    npairs.add_rules({
      Rule('"""', '"""', "python"),
    })
  end,
}
