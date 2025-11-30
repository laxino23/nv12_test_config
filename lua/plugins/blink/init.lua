local source = require("plugins.blink.source").source

vim.pack.add({
  { src = "https://github.com/archie-judd/blink-cmp-words" },
  { src = "https://github.com/rafamadriz/friendly-snippets" },
  { src = "https://github.com/saghen/blink.compat", version = "main" },
  { src = "https://github.com/supermaven-inc/supermaven-nvim" },
  { src = "https://github.com/saghen/blink.cmp", version = "v1.7.0" },
  { src = "https://github.com/L3MON4D3/LuaSnip" },
})

vim.api.nvim_create_autocmd({ "InsertEnter", "CmdlineEnter" }, {
  group = vim.api.nvim_create_augroup("SetupCompletion", { clear = true }),
  once = true,
  callback = function()
    -- 2. SETUP COMPATIBILITY LAYER (Required before blink.cmp setup)
    require("blink.compat").setup({ impersonate_nvim_cmp = true })

    -- 3. SETUP SUPERMAVEN
    -- We disable the native ghost text so Blink handles the UI
    require("supermaven-nvim").setup({
      disable_inline_completion = true,
      disable_keymaps = true,
      keymaps = {
        accept_suggestion = "<C-a>",
        clear_suggestion = "<Esc>",
        accept_word = "<C-w>",
      },
      color = {
        suggestion_color = "#ffffff",
        cterm = 244,
      },
      log_level = "info",
    })

    -- 4. SETUP BLINK
    require("blink.cmp").setup({
      -- Completion UI
      completion = {
        documentation = {
          auto_show = true,
          window = { border = "single", scrollbar = false },
        },
        menu = {
          border = "single",
          auto_show = true,
          auto_show_delay_ms = 0,
          scrollbar = false,
        },
      },
      snippets = {
        preset = "luasnip", -- the engine
      },
      -- Keymaps
      keymap = {
        preset = "default",
        ["<C-u>"] = { "scroll_documentation_up", "fallback" },
        ["<C-d>"] = { "scroll_documentation_down", "fallback" },
        ["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
        ["<CR>"] = { "accept", "fallback" },
        ["<Tab>"] = {
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

      -- Function Signature Help
      signature = {
        enabled = true,
        window = {
          show_documentation = false,
          border = "single",
        },
      },
      -- Cmdline UI
      cmdline = {
        completion = { menu = { auto_show = true } },
        sources = function()
          local type = vim.fn.getcmdtype()
          if type == "/" or type == "?" then
            return { "buffer" }
          end
          if type == ":" then
            return { "cmdline", "path" }
          end
          return {}
        end,
      },
      -- customized source
      sources = source,
    })
  end,
})
