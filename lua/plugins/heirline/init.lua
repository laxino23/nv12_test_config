-- 使用 vim.pack.add 添加所有所需插件
vim.pack.add({
  { src = "https://github.com/linrongbin16/lsp-progress.nvim" },
  { src = "https://github.com/rebelot/heirline.nvim" },
  { src = "https://github.com/lewis6991/gitsigns.nvim" },
  { src = "https://github.com/mfussenegger/nvim-dap" },
})

-- 创建 autocmd，在第一个缓冲区读取时一次性设置插件
vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
  group = vim.api.nvim_create_augroup("SetupHeirline", { clear = true }),
  once = true,
  callback = function()
    -- 设置 lsp-progress
    require("lsp-progress").setup()

    -- 设置 gitsigns（默认配置，用于 Git 集成）
    require("gitsigns").setup()

    -- 设置 nvim-dap（基本初始化）
    local dap = require("dap")
    dap.adapters = {} -- 示例：在这里添加您的调试适配器配置
    dap.configurations = {} -- 示例：添加语言特定配置

    -- 设置 heirline，使用您的 statusline 配置
    -- 注意：只有在 heirline 加载后才能 require statusline
    require("heirline").setup({
      statusline = require("plugins.heirline.statusline"),
    })

    -- 设置 lsp-progress 的自动命令，用于更新状态栏
    vim.api.nvim_create_augroup("lsp_progress_augroup", { clear = true })
    vim.api.nvim_create_autocmd("User", {
      group = "lsp_progress_augroup",
      pattern = "LspProgressStatusUpdated",
      callback = vim.schedule_wrap(function()
        vim.cmd("redrawstatus")
      end),
    })
  end,
})
