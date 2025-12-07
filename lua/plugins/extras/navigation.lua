local map = require("config.keymaps").map

-- ============================================================================
-- Flash.nvim
-- ============================================================================
map({
  ["Flash"] = {
    { "n", "x", "o" },
    "s",
    function()
      require("flash").jump()
    end,
  },
  ["Flash Treesitter"] = {
    { "n", "x", "o" },
    "S",
    function()
      require("flash").treesitter()
    end,
  },
  ["Remote Flash"] = {
    "o",
    "r",
    function()
      require("flash").remote()
    end,
  },
  ["Treesitter Search"] = {
    { "o", "x" },
    "R",
    function()
      require("flash").treesitter_search()
    end,
  },
  ["Toggle Flash Search"] = {
    "c",
    "<c-s>",
    function()
      require("flash").toggle()
    end,
  },
})

-- ============================================================================
-- Better Escape
-- ============================================================================
vim.api.nvim_create_autocmd("InsertEnter", {
  once = true,
  callback = function()
    require("better_escape").setup({
      timeout = 300,
      default_mappings = false,
      mappings = { i = { j = { k = "<Esc>", j = "<Esc>" } } },
    })
  end,
})
