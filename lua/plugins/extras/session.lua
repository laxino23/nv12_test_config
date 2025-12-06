local map = require("config.keymaps").map
local persistence = require("persistence")

-- Configure sessionoptions
vim.opt.sessionoptions = {
  "buffers",
  "curdir",
  "tabpages",
  "winsize",
  "help",
  "globals",
  "skiprtp",
  "folds",
  "blank",
  "terminal",
}
vim.opt.viewoptions = { "folds", "cursor", "curdir", "options" }

persistence.setup({
  dir = vim.fn.stdpath("state") .. "/sessions/",
  need = 0,
  branch = true,
})

-- Keymaps
map({
  ["save"] = { "n", "<leader>ww", ":w<CR>" },
  ["save-and-quit"] = {
    "n",
    "<leader>wq",
    function()
      vim.cmd("w")
      vim.cmd("wshada!")
      persistence.save()
      vim.cmd("qa!")
    end,
  },
  ["quit-without-session"] = {
    "n",
    "<leader>wa",
    function()
      persistence.stop()
      vim.cmd("qa!")
    end,
  },
  ["quit-special-buf"] = {
    "n",
    "<leader>we",
    function()
      vim.cmd("q")
    end,
  },
  ["force-quit"] = {
    "n",
    "<leader>wx",
    function()
      persistence.stop()
      vim.cmd("qa!")
    end,
  },
  ["session-save"] = {
    "n",
    "<leader>qs",
    function()
      vim.cmd("wshada!")
      persistence.save()
    end,
    "手动保存当前会话",
  },
  ["session-load"] = {
    "n",
    "<leader>ql",
    function()
      persistence.load()
      vim.cmd("rshada!")
    end,
    "恢复当前项目会话",
  },
  ["session-load-last"] = {
    "n",
    "<leader>qL",
    function()
      persistence.load({ last = true })
      vim.cmd("rshada!")
    end,
    "恢复最后一次会话",
  },
  ["session-stop"] = { "n", "<leader>qd", persistence.stop, "本次退出不保存会话" },
}, { silent = true })

-- Auto-load logic
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() == 0 then
      local buf_name = vim.api.nvim_buf_get_name(0)
      local buf_lines = vim.api.nvim_buf_line_count(0)
      if buf_name == "" and buf_lines == 1 then
        local first_line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]
        if first_line == "" then
          vim.schedule(function()
            persistence.load({ last = true })
            vim.cmd("rshada!")
            print("✓ Auto-loaded last session")
          end)
        end
      end
    end
  end,
  nested = true,
})
