local ui = require("config.ui")

return {
  -- =========================================================================
  -- 1. nvim-web-devicons: 基础图标库 (文件图标)
  -- =========================================================================
  { "nvim-tree/nvim-web-devicons", opts = {} },

  -- =========================================================================
  -- 2. lspkind.nvim: 为补全列表提供标准的类型图标 (Function, Variable 等)
  -- =========================================================================
  {
    "onsails/lspkind.nvim",
    config = function()
      require("lspkind").init({
        -- 使用 core.ui 中定义的图标映射，确保全编辑器风格统一
        symbol_map = ui.icons.lspkind_kind_icons,
      })
    end,
  },

  -- =========================================================================
  -- 3. LuaSnip: 代码片段引擎
  -- =========================================================================
  {
    "L3MON4D3/LuaSnip",
    -- 安装 jsregexp 以支持更复杂的正则表达式片段
    build = "make install_jsregexp",
    lazy = true,
    -- 依赖 friendly-snippets (包含大量预设的常用语言片段)
    dependencies = { { "rafamadriz/friendly-snippets", lazy = true } },
    config = function()
      local ls = require("luasnip")
      ls.config.setup({
        enable_autosnippets = true, -- 启用自动触发的片段
        history = true, -- 允许跳回之前的片段节点
        updateevents = "TextChanged,TextChangedI", -- 实时更新片段内容
        delete_check_events = "TextChanged",
        region_check_events = "CursorMoved",
      })

      -- 文件类型扩展：在 typescript/react 文件中也能使用 javascript 的片段
      ls.filetype_extend("typescript", { "javascript" })
      ls.filetype_extend("javascriptreact", { "javascript" })
      ls.filetype_extend("typescriptreact", { "javascript" })

      -- 加载各种格式的 snippets
      vim.tbl_map(function(type)
        require("luasnip.loaders.from_" .. type).lazy_load()
      end, { "vscode", "snipmate", "lua" })
    end,
  },

  -- =========================================================================
  -- 4. blink.cmp: 核心补全引擎 (Rust 高性能版)
  -- =========================================================================
  {
    "Saghen/blink.cmp",
    dependencies = {
      { "fang2hou/blink-copilot" }, -- Copilot 接入 blink
      { "folke/lazydev.nvim" }, -- 智能 Lua 配置补全
      { "folke/sidekick.nvim" }, -- AI 辅助工具
      { "nicholasxjy/colorful-menu.nvim", opts = {} }, -- 让补全菜单显示更丰富的颜色 (比如 rust 类型颜色)
    },
    build = "cargo build --release", -- 编译 Rust 后端
    event = { "InsertEnter", "CmdlineEnter" }, -- 在插入模式或命令行输入时加载

    opts = function()
      return {
        -- === 启用逻辑 ===
        enabled = function()
          -- 在大文件、snacks 输入框、prompt 缓冲区中禁用补全
          return not vim.tbl_contains(
            { "bigfile", "grug-far", "snacks_picker", "snacks_picker_input" },
            vim.bo.filetype
          ) and vim.b.completion ~= false and vim.bo.buftype ~= "prompt"
        end,

        -- === 模糊匹配设置 ===
        fuzzy = {
          implementation = "prefer_rust", -- 优先使用 Rust 实现的匹配算法 (极快)
          sorts = {
            "exact",
            "score",
            "sort_text",
            "label", -- 排序规则
          },
        },

        -- === 快捷键设置 ===
        keymap = {
          ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
          ["<Up>"] = { "select_prev", "fallback" },
          ["<Down>"] = { "select_next", "fallback" },
          ["<C-n>"] = { "select_next", "show" },
          ["<C-p>"] = { "select_prev", "show" },
          ["<C-j>"] = { "select_next", "fallback" },
          ["<C-k>"] = { "select_prev", "fallback" },
          ["<C-u>"] = { "scroll_documentation_up", "fallback" },
          ["<C-d>"] = { "scroll_documentation_down", "fallback" },
          ["<C-e>"] = { "hide", "fallback" },
          ["<CR>"] = { "accept", "fallback" }, -- 回车确认

          -- [!] 超级 Tab 键逻辑：
          -- 1. 尝试 Sidekick 跳转 (AI)
          -- 2. 尝试代码片段跳转 (Snippet Forward)
          -- 3. 选择下一个补全项
          ["<Tab>"] = {
            function()
              return require("sidekick").nes_jump_or_apply()
            end,
            "snippet_forward",
            "select_next",
            "fallback",
          },
          ["<S-Tab>"] = {
            "snippet_backward",
            "select_prev",
            "fallback",
          },
        },

        -- === 函数签名提示 (输入参数时显示) ===
        signature = {
          enabled = true,
          window = {
            show_documentation = true,
            border = "rounded",
          },
        },

        -- === 补全窗口外观 ===
        completion = {
          ghost_text = { enabled = true }, -- 显示灰色幽灵文本预览
          documentation = {
            auto_show = true,
            auto_show_delay_ms = 100,
            window = {
              -- 动态边框：如果全局变量 vim.g.bordered 为真，则绘制复杂边框
              border = vim.g.bordered and {
                { "", "DiagnosticHint" },
                "─",
                "╮",
                "│",
                "╯",
                "─",
                "╰",
                "│",
              } or "none",
              max_height = 20,
              max_width = 40,
            },
          },
          accept = { auto_brackets = { enabled = true } }, -- 补全函数后自动加括号 ()
          list = { selection = { preselect = true, auto_insert = true } },

          -- 补全菜单渲染 (核心视觉部分)
          menu = {
            scrollbar = false,
            border = vim.g.bordered and {
              { "󱐋", "WarningMsg" },
              "─",
              "╮",
              "│",
              "╯",
              "─",
              "╰",
              "│",
            } or "none",

            -- 自定义绘制列
            draw = {
              columns = {
                { "kind_icon" }, -- 第一列：图标
                { "label", gap = 1 }, -- 第二列：文字标签
                { "kind" }, -- 第三列：类型名称 (如 [Function])
              },
              treesitter = { "lsp" }, -- 使用 LSP 的 Treesitter 高亮

              -- 使用 colorful-menu 插件来渲染组件
              -- 这能让补全菜单里的类型颜色更加丰富（例如不同类型的变量显示不同颜色）
              components = {
                label = {
                  text = function(ctx)
                    return require("colorful-menu").blink_components_text(ctx)
                  end,
                  highlight = function(ctx)
                    return require("colorful-menu").blink_components_highlight(ctx)
                  end,
                },
                kind_icon = {
                  text = function(ctx)
                    -- 特殊处理文件路径图标
                    if vim.tbl_contains({ "Path" }, ctx.source_name) then
                      local mini_icon, _ =
                        require("mini.icons").get_icon(ctx.item.data.type, ctx.label)
                      if mini_icon then
                        return mini_icon .. ctx.icon_gap
                      end
                    end
                    -- 使用 lspkind 图标
                    local icon = require("lspkind").symbolic(ctx.kind, { mode = "symbol" })
                    return icon .. ctx.icon_gap
                  end,
                  highlight = function(ctx)
                    -- 特殊处理文件路径高亮
                    if vim.tbl_contains({ "Path" }, ctx.source_name) then
                      local mini_icon, mini_hl =
                        require("mini.icons").get_icon(ctx.item.data.type, ctx.label)
                      if mini_icon then
                        return mini_hl
                      end
                    end
                    return ctx.kind_hl
                  end,
                },
                -- kind 列同理...
                kind = {
                  text = function(ctx)
                    return "[" .. ctx.kind .. "]"
                  end,
                  highlight = function(ctx)
                    -- ... (同上，省略部分重复代码)
                    if vim.tbl_contains({ "Path" }, ctx.source_name) then
                      local mini_icon, mini_hl =
                        require("mini.icons").get_icon(ctx.item.data.type, ctx.label)
                      if mini_icon then
                        return mini_hl
                      end
                    end
                    return ctx.kind_hl
                  end,
                },
              },
            },
          },
        },

        -- === 命令行补全 (:) ===
        cmdline = {
          enabled = true,
          keymap = {
            -- 命令行专用快捷键
            ["<Up>"] = { "select_prev", "fallback" },
            ["<Down>"] = { "select_next", "fallback" },
            ["<C-n>"] = { "select_next", "show" },
            ["<C-p>"] = { "select_prev", "show" },
            ["<Tab>"] = {
              function()
                return require("sidekick").nes_jump_or_apply()
              end,
              "snippet_forward",
              "select_next",
              "fallback",
            },
          },
          completion = {
            ghost_text = { enabled = true },
            menu = {
              auto_show = function()
                return vim.fn.getcmdtype() == ":"
              end, -- 仅在 : 命令模式显示
            },
          },
        },

        snippets = { preset = "luasnip" }, -- 指定使用 luasnip 引擎

        -- === 补全源 ===
        sources = {
          -- 默认启用的源
          -- 注意：你把 "copilot" 注释掉了，如果需要开启 Copilot 补全，取消注释即可
          default = { "lazydev", "lsp", "path", "snippets", "buffer" }, --"copilot"
          providers = {
            -- Copilot 源配置
            copilot = {
              name = "copilot",
              module = "blink-copilot",
              async = true,
              score_offset = 100, -- 让 Copilot 排名靠前
              enabled = function()
                return vim.g.copilot_enabled
              end,
              opts = {
                max_completions = 3,
                max_items = 2,
              },
            },
            -- LazyDev 源配置 (编写 Neovim 配置时非常有用)
            lazydev = {
              name = "LazyDev",
              module = "lazydev.integrations.blink",
              score_offset = 100,
            },
          },
        },
      }
    end,

    config = function(_, opts)
      require("blink.cmp").setup(opts)

      -- 手动通知所有 LSP 服务器：我们支持 blink.cmp 的能力
      -- 虽然 blink.cmp 通常会自动处理，但显式声明更加稳妥
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      vim.tbl_deep_extend("force", capabilities, {
        workspace = { fileOperations = { didRename = true, willRename = true } },
        textDocument = { foldingRange = { dynamicRegistration = false, lineFoldingOnly = true } },
      })
      capabilities = vim.tbl_deep_extend(
        "force",
        capabilities,
        require("blink.cmp").get_lsp_capabilities(capabilities, true)
      )

      -- 更新所有 LSP 的配置
      vim.lsp.config("*", {
        capabilities = capabilities,
      })
    end,
  },
}
