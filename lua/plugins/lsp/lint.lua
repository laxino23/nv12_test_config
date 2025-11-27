return {
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")

      -- 配置各种文件类型对应的 linter 工具
      -- sh 文件使用 shellcheck 检查
      -- dockerfile 使用 hadolint 检查
      -- JavaScript/TypeScript 文件使用 eslint 检查
      -- Go 文件使用 golangcilint 检查
      local linters_by_ft = {
        sh = { "shellcheck" },
        dockerfile = { "hadolint" },
        javascript = { "eslint" },
        typescript = { "eslint" },
        typescriptreact = { "eslint" },
        javascriptreact = { "eslint" },
        go = { "golangcilint" },
      }

      lint.linters_by_ft = linters_by_ft

      -- 防抖函数:延迟执行,避免频繁触发 linting
      -- ms: 延迟毫秒数
      -- fn: 要执行的函数
      local function debounce(ms, fn)
        local timer = assert(vim.uv.new_timer())
        return function(...)
          local argv = { ... }
          timer:start(ms, 0, function()
            timer:stop()
            vim.schedule_wrap(fn)(unpack(argv))
          end)
        end
      end

      -- 创建自动命令,在以下事件触发时自动执行 linting:
      -- BufEnter: 进入缓冲区时
      -- BufWritePost: 保存文件后
      -- InsertLeave: 退出插入模式时
      -- 使用 100 毫秒防抖,避免过于频繁地检查
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = vim.api.nvim_create_augroup("xue-nvim-lint", { clear = true }),
        callback = debounce(100, function()
          require("lint").try_lint()
        end),
      })

      -- 设置快捷键 <leader>cL 手动触发当前文件的 linting 检查
      vim.keymap.set("n", "<leader>cL", function()
        lint.try_lint()
      end, { desc = "Trigger linting for current file" })
    end,
  },
}
