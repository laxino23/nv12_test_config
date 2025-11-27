return {
  {
    "folke/flash.nvim",
    event = "VeryLazy",

    -- === [核心亮点] 集成 Snacks.nvim ===
    -- 这里通过 specs 告诉 Lazy：当加载 flash 时，顺便去配置 snacks.nvim
    specs = {
      {
        "folke/snacks.nvim",
        opts = {
          picker = {
            win = {
              input = {
                keys = {
                  -- 在 Snacks Picker 输入框中，按 <Alt-s> 或 s 触发 Flash 跳转
                  ["<a-s>"] = { "flash", mode = { "n", "i" } },
                  ["s"] = { "flash" },
                },
              },
            },
            actions = {
              flash = function(picker)
                require("flash").jump({
                  pattern = "^", -- 匹配每一行的行首
                  label = { after = { 0, 0 } }, -- 标签显示位置
                  search = {
                    mode = "search",
                    exclude = {
                      function(win)
                        return vim.bo[vim.api.nvim_win_get_buf(win)].filetype
                          ~= "snacks_picker_list"
                      end,
                    },
                  },
                  action = function(match)
                    local idx = picker.list:row2idx(match.pos[1])
                    picker.list:_move(idx, true, true)
                  end,
                })
              end,
            },
          },
        },
      },
    },

    -- === Flash 自身外观配置 ===
    opts = {
      label = {
        uppercase = false, -- 使用小写字母作为跳转标签
        rainbow = {
          enabled = true, -- 开启彩虹色标签
          shade = 5, -- 阴影深度
        },
      },
    },

    -- === 全局快捷键映射 ===
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash Jump",
        remap = false,
      },
      {
        "S",
        mode = { "n", "o", "x" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter", -- 比如快速选中整个函数或if块
      },
      {
        "r",
        mode = "o", -- 仅在 Operator-pending 模式下有效 (比如 y, d 之后)
        function()
          require("flash").remote()
        end,
        desc = "Remote Flash", -- 用于对远处文本执行 y/d 操作而不移动光标
      },
      {
        "R",
        mode = { "o", "x" },
        function()
          require("flash").treesitter_search()
        end,
        desc = "Treesitter Search",
      },
      {
        "<c-s>",
        mode = { "c" }, -- 命令行模式
        function()
          require("flash").toggle()
        end,
        desc = "Toggle Flash Search",
      },
    },
  },
}
