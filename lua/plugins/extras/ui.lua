local map = require("config.keymaps").map

-- ============================================================================
-- Mini.icons
-- ============================================================================
require("mini.icons").setup({
  file = {
    [".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
    ["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
    [".go-version"] = { glyph = "", hl = "MiniIconsBlue" },
    [".eslintrc.js"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
    [".node-version"] = { glyph = "", hl = "MiniIconsGreen" },
    [".prettierrc"] = { glyph = "", hl = "MiniIconsPurple" },
    [".yarnrc.yml"] = { glyph = "", hl = "MiniIconsBlue" },
    ["eslint.config.js"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
    ["package.json"] = { glyph = "", hl = "MiniIconsGreen" },
    ["tsconfig.json"] = { glyph = "", hl = "MiniIconsAzure" },
    ["tsconfig.build.json"] = { glyph = "", hl = "MiniIconsAzure" },
    ["yarn.lock"] = { glyph = "", hl = "MiniIconsBlue" },
  },
  filetype = {
    dotenv = { glyph = "", hl = "MiniIconsYellow" },
    gotmpl = { glyph = "󰟓", hl = "MiniIconsGrey" },
    postcss = { glyph = "󰌜", hl = "MiniIconsOrange" },
  },
})
require("mini.icons").mock_nvim_web_devicons()

-- ============================================================================
-- Mini.trailspace
-- ============================================================================
require("mini.trailspace").setup({ only_in_normal_buffers = true })
map({
  ["Trailspace"] = {
    "n",
    "<leader>ut",
    function()
      require("mini.trailspace").trim()
    end,
  },
})

-- ============================================================================
-- Mini.clue
-- ============================================================================
local miniclue = require("mini.clue")
miniclue.setup({
  triggers = {
    { mode = "n", keys = "<Leader>" },
    { mode = "x", keys = "<Leader>" },
    { mode = "i", keys = "<C-x>" },
    { mode = "n", keys = "g" },
    { mode = "x", keys = "g" },
    { mode = "n", keys = "'" },
    { mode = "n", keys = "`" },
    { mode = "n", keys = '"' },
    { mode = "n", keys = "<C-w>" },
    { mode = "n", keys = "z" },
  },
  clues = {
    { mode = "n", keys = "<leader>a", desc = "+ai" },
    { mode = "n", keys = "<leader>c", desc = "+codes" },
    { mode = "n", keys = "<leader>f", desc = "+find" },
    { mode = "n", keys = "<leader>s", desc = "+search/win split" },
    { mode = "n", keys = "<leader>x", desc = "+diagnostics" },
    { mode = "n", keys = "<leader>g", desc = "+git/go to" },
    { mode = "n", keys = "<leader>gh", desc = "+git" },
    { mode = "n", keys = "<leader>gt", desc = "+go to" },
    { mode = "n", keys = "<leader>u", desc = "+ui" },
    { mode = "n", keys = "<leader>b", desc = "+buffers" },
    { mode = "n", keys = "<leader>d", desc = "+debug" },
    miniclue.gen_clues.builtin_completion(),
    miniclue.gen_clues.g(),
    miniclue.gen_clues.marks(),
    miniclue.gen_clues.registers(),
    miniclue.gen_clues.windows(),
    miniclue.gen_clues.z(),
  },
  window = { delay = 200, config = { width = 50, border = "single" } },
})

-- ============================================================================
-- Lazy Visuals (Cursors, Whitespace, Screenkey)
-- ============================================================================
local lazy_ui_group = vim.api.nvim_create_augroup("ConfigLazyUI", { clear = true })

-- Screenkey Command
vim.api.nvim_create_user_command("ScreenkeyToggle", function()
  if not package.loaded["screenkey"] then
    require("screenkey").setup({
      win_opts = {
        row = vim.o.lines - vim.o.cmdheight - 1,
        col = vim.o.columns - 1,
        relative = "editor",
        anchor = "SE",
        width = 20,
        height = 2,
        border = "single",
        title = "Screenkey",
        title_pos = "center",
        style = "minimal",
        focusable = false,
        noautocmd = true,
      },
      hl_groups = {
        ["screenkey.hl.key"] = { link = "Type" },
        ["screenkey.hl.map"] = { link = "Keyword" },
        ["screenkey.hl.sep"] = { link = "Normal" },
      },
    })
  end
  require("screenkey").toggle()
end, {})
vim.keymap.set("n", "<leader>uk", ":ScreenkeyToggle<CR>", { desc = "Screenkey Toggle" })

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  group = lazy_ui_group,
  once = true,
  callback = function()
    require("visual-whitespace").setup({})
    require("virt-column").setup({ char = "", virtcolumn = "80" })

    -- SmoothCursor
    require("smoothcursor").setup({
      type = "default",
      autostart = true,
      fancy = {
        enable = true,
        head = { cursor = ">", texthl = "SmoothCursor" },
        body = {
          { cursor = "󰝥", texthl = "SmoothCursorRed" },
          { cursor = "󰝥", texthl = "SmoothCursorOrange" },
          { cursor = "●", texthl = "SmoothCursorYellow" },
          { cursor = "●", texthl = "SmoothCursorGreen" },
          { cursor = "•", texthl = "SmoothCursorAqua" },
          { cursor = ".", texthl = "SmoothCursorBlue" },
          { cursor = ".", texthl = "SmoothCursorPurple" },
        },
        tail = { cursor = nil, texthl = "SmoothCursor" },
      },
      disabled_filetypes = {
        "render-markdown",
        "CodeCompanion",
        "oil",
        "snacks_picker_input",
        "fzf",
      },
    })

    -- Smear Cursor
    require("smear_cursor").setup({
      stiffness = 0.8,
      trailing_stiffness = 0.6,
      distance_stop_animating = 0.5,
      time_interval = 10,
      cursor_color = "#a020f0",
      particles_enabled = true,
      particles_per_second = 200,
      particle_max_lifetime = 400,
      particle_gravity = -20,
      particle_velocity_from_cursor = 0.3,
      legacy_computing_symbols_support = true,
      smear_between_buffers = true,
      smear_between_neighbor_lines = true,
      hide_target_hack = false,
    })
  end,
})
