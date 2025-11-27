-- ===========================================================================
-- 辅助函数：在 mini.files 中以分屏方式打开文件
-- ===========================================================================
local function open_buf_in_split(buf_id, key_map, direction)
  local MiniFiles = require("mini.files")

  local function rhs()
    local cur_target = MiniFiles.get_explorer_state().target_window

    -- 如果文件浏览器未打开，或者当前光标停在文件夹上，则不做任何操作
    if cur_target == nil or MiniFiles.get_fs_entry().fs_type == "directory" then
      return
    end

    -- 创建一个新的分屏窗口，并将其设置为目标窗口
    local new_target = vim.api.nvim_win_call(cur_target, function()
      vim.cmd(direction .. " split")
      return vim.api.nvim_get_current_win()
    end)
    MiniFiles.set_target_window(new_target)

    -- 进入该文件并关闭文件浏览器
    MiniFiles.go_in({ close_on_file = true })
  end

  -- 注册快捷键
  vim.keymap.set("n", key_map, rhs, { buffer = buf_id, desc = "Split " .. string.sub(direction, 12) })
end

return {
  -- =========================================================================
  -- 1. mini.icons: 图标库 (替代 nvim-web-devicons)
  -- =========================================================================
  {
    "nvim-mini/mini.icons",
    lazy = true,
    version = false,
    opts = {
      -- 自定义特定文件的图标和颜色
      file = {
        [".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
        ["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
        ["package.json"] = { glyph = "", hl = "MiniIconsGreen" },
        ["tsconfig.json"] = { glyph = "", hl = "MiniIconsAzure" },
        -- ... 其他自定义图标
      },
      -- 自定义文件类型的图标
      filetype = {
        dotenv = { glyph = "", hl = "MiniIconsYellow" },
      },
    },
    init = function()
      -- [!] 关键：模拟 nvim-web-devicons
      -- 让其他依赖 nvim-web-devicons 的插件（如 lualine, bufferline）自动使用 mini.icons
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },

  -- =========================================================================
  -- 2. mini.ai: 增强的文本对象 (Text Objects)
  --    让你可以通过 vaa (select around argument), daf (delete around function) 操作代码
  -- =========================================================================
  {
    "nvim-mini/mini.ai",
    version = false,
    event = "VeryLazy",
    opts = function()
      local ai = require("mini.ai")
      return {
        n_lines = 500, -- 搜索范围：前后 500 行
        custom_textobjects = {
          ["?"] = false, -- 禁用 ?
          ["/"] = ai.gen_spec.user_prompt(), -- 允许通过正则搜索来定义对象
          
          -- %: 选中整个文件 (Content)
          ["%"] = function() 
            local from = { line = 1, col = 1 }
            local to = {
              line = vim.fn.line("$"),
              col = math.max(vim.fn.getline("$"):len(), 1),
            }
            return { from = from, to = to }
          end,
          
          -- 基于 Treesitter 的智能选择
          a = ai.gen_spec.treesitter({ a = "@parameter.outer", i = "@parameter.inner" }), -- 参数
          c = ai.gen_spec.treesitter({ a = "@comment.outer", i = "@comment.inner" }),     -- 注释
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),   -- 函数
          
          -- s: 选中驼峰命名或下划线命名的“单词片段” (Sub-word)
          s = { 
            {
              "%u[%l%d]+%f[^%l%d]",
              "%f[^%s%p][%l%d]+%f[^%l%d]",
              "^[%l%d]+%f[^%l%d]",
              "%f[^%s%p][%a%d]+%f[^%a%d]",
              "^[%a%d]+%f[^%a%d]",
            },
            "^().*()$",
          },
        },
        mappings = {
          around = "a", -- 包含边界 (Around)
          inside = "i", -- 内部 (Inside)
        },
      }
    end,
  },

  -- =========================================================================
  -- 3. mini.surround: 包围符号操作 (替代 vim-surround)
  -- =========================================================================
  {
    "nvim-mini/mini.surround",
    version = false,
    event = "VeryLazy",
    opts = {
      mappings = {
        add = "gsa",     -- 添加包围: gsa + 范围 + 符号 (如 gsaiw")
        delete = "gsd",  -- 删除包围: gsd"
        replace = "gsr", -- 替换包围: gsr"'
      },
    },
    config = function(_, opts)
      require("mini.surround").setup(opts)
    end,
  },

  -- =========================================================================
  -- 4. mini.splitjoin: 代码分行与合并 (替代 splitjoin.vim)
  --    用于将单行参数列表变为多行，或反之
  -- =========================================================================
  {
    "nvim-mini/mini.splitjoin",
    version = false,
    event = "VeryLazy",
    config = function()
      local miniSplitJoin = require("mini.splitjoin")
      miniSplitJoin.setup({
        mappings = { toggle = "gS" }, -- 快捷键: gS
      })
    end,
  },

  -- =========================================================================
  -- 5. mini.trailspace: 尾部空格处理
  -- =========================================================================
  {
    "nvim-mini/mini.trailspace",
    version = false,
    event = "VeryLazy",
    keys = {
      {
        "<leader>ut", -- 快捷键：手动清理尾部空格
        function() require("mini.trailspace").trim() end,
        desc = "Trailspace",
      },
    },
    config = function()
      require("mini.trailspace").setup({
        only_in_normal_buffers = true, -- 仅在普通缓冲区生效 (不包括终端等)
      })
    end,
  },

  -- =========================================================================
  -- 6. mini.clue: 按键提示 (替代 which-key.nvim)
  -- =========================================================================
  {
    "nvim-mini/mini.clue",
    version = false,
    event = "VeryLazy",
    keys = {
      -- 注册需要显示提示的按键前缀
      { "<leader>a", "", desc = "+ai" },
      { "<leader>c", "", desc = "+codes" },
      -- ... 其他前缀
    },
    config = function()
      local miniclue = require("mini.clue")
      miniclue.setup({
        triggers = {
          -- 触发条件
          { mode = "n", keys = "<Leader>" }, -- 按下 Leader 键触发
          { mode = "x", keys = "<Leader>" },
          { mode = "i", keys = "<C-x>" },    -- 插入模式补全触发
          { mode = "n", keys = "g" },        -- g 键触发
          { mode = "n", keys = "'" },        -- 标记触发
          { mode = "n", keys = '"' },        -- 寄存器触发
          { mode = "n", keys = "<C-w>" },    -- 窗口命令触发
          { mode = "n", keys = "z" },        -- 折叠命令触发
        },
        clues = {
          -- 加载内置的提示增强
          miniclue.gen_clues.builtin_completion(),
          miniclue.gen_clues.g(),
          miniclue.gen_clues.marks(),
          miniclue.gen_clues.registers(),
          miniclue.gen_clues.windows(),
          miniclue.gen_clues.z(),
        },
        window = {
          delay = 200, -- 延迟 200ms 显示
          config = { border = "single" },
        },
      })
    end,
  },

  -- =========================================================================
  -- 7. mini.files: 文件管理器 (替代 nvim-tree / oil.nvim)
  --    这是配置中最复杂也是最强大的部分
  -- =========================================================================
  {
    "nvim-mini/mini.files",
    version = false,
    event = "VeryLazy",
    keys = {
      {
        "<leader>e",
        function()
          -- 智能打开逻辑：优先打开当前文件所在的目录
          local bufname = vim.api.nvim_buf_get_name(0)
          local path = vim.fn.fnamemodify(bufname, ":p")

          if path and vim.uv.fs_stat(path) then
            require("mini.files").open(bufname, false)
          else
            require("mini.files").open()
          end
        end,
        desc = "File explorer",
      },
    },
    opts = {
      mappings = {
        show_help = "?",
        go_in_plus = "<cr>", -- 回车进入目录/打开文件
        go_out_plus = "-",   -- 减号返回上一级
      },
      content = {
        filter = function(entry)
          return entry.name ~= ".DS_Store" -- 过滤掉 macOS 的垃圾文件
        end,
      },
      options = { permanent_delete = false }, -- 删除文件时移入垃圾桶，而不是永久删除
    },
    config = function(_, opts)
      require("mini.files").setup(opts)

      -- 1. 窗口样式美化：打开时设置边框
      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesWindowOpen",
        callback = function(args)
          local win_id = args.data.win_id
          vim.wo[win_id].winblend = 0
          local config = vim.api.nvim_win_get_config(win_id)
          config.border = "single"
          vim.api.nvim_win_set_config(win_id, config)
        end,
      })

      -- 2. 快捷键增强：创建 Buffer 时绑定按键
      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesBufferCreate",
        callback = function(args)
          local buf_id = args.data.buf_id
          -- g. 切换隐藏文件显示
          vim.keymap.set("n", "g.", function()
            vim.g.show_dotfiles = not vim.g.show_dotfiles
            require("mini.files").refresh({
              content = {
                filter = function(entry)
                  return vim.g.show_dotfiles or entry.name:sub(1, 1) ~= "."
                end,
              },
            })
          end, { buffer = buf_id, desc = "Toggle `.`-files" })
        end,
      })

      -- 3. 分屏打开支持：调用文件开头的 open_buf_in_split 函数
      vim.api.nvim_create_autocmd("User", {
        desc = "Add minifiles split keymaps",
        pattern = "MiniFilesBufferCreate",
        callback = function(args)
          local buf_id = args.data.buf_id
          open_buf_in_split(buf_id, "<C-h>", "topleft vertical")    -- Ctrl+h 左分屏
          open_buf_in_split(buf_id, "<C-j>", "belowright horizontal") -- Ctrl+j 下分屏
          open_buf_in_split(buf_id, "<C-k>", "topleft horizontal")    -- Ctrl+k 上分屏
          open_buf_in_split(buf_id, "<C-l>", "belowright vertical")   -- Ctrl+l 右分屏
          open_buf_in_split(buf_id, "<C-t>", "tab")                   -- Ctrl+t 新标签页
        end,
      })

      -- 4. [高级功能] LSP 自动重命名同步
      -- 当你在 mini.files 里重命名一个文件时，自动通知 LSP 服务器
      -- 这样你项目里所有引用这个文件的地方都会自动更新
      vim.api.nvim_create_autocmd("User", {
        desc = "Notify LSPs that a file was renamed",
        pattern = "MiniFilesActionRename",
        callback = function(args)
          local changes = {
            files = {
              {
                oldUri = vim.uri_from_fname(args.data.from),
                newUri = vim.uri_from_fname(args.data.to),
              },
            },
          }
          local will_rename_method, did_rename_method =
            vim.lsp.protocol.Methods.workspace_willRenameFiles, vim.lsp.protocol.Methods.workspace_didRenameFiles
          local clients = vim.lsp.get_clients()
          
          -- 步骤 A: 告诉 LSP "我要改名了"，让 LSP 返回需要修改的代码位置 (WorkspaceEdit)
          for _, client in ipairs(clients) do
            if client:supports_method(will_rename_method) then
              local res = client:request_sync(will_rename_method, changes, 1000, 0)
              if res and res.result then
                vim.lsp.util.apply_workspace_edit(res.result, client.offset_encoding)
              end
            end
          end

          -- 步骤 B: 告诉 LSP "我已经改名了"
          for _, client in ipairs(clients) do
            if client:supports_method(did_rename_method) then
              client:notify(did_rename_method, changes)
            end
          end
        end,
      })
    end,
  },
}
