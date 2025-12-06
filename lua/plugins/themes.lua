vim.pack.add({
  { src = "https://github.com/catppuccin/nvim" },
  { src = "https://github.com/maxmx03/fluoromachine.nvim" },
  { src = "https://github.com/ribru17/bamboo.nvim" },
  { src = "https://github.com/uga-rosa/ccc.nvim" },
})
-- ccc setup
require("ccc").setup({
  highlighter = {
    auto_enable = true,
    lsp = true,
  },
})

-- bamboo setup
local opts = {
  style = "multiplex", -- Choose between 'vulgaris' (regular), 'multiplex' (greener), and 'light'
  transparent = vim.g.transparent,
  lualine = {
    transparent = true, -- lualine center bar transparency
  },
  code_style = {
    comments = { italic = true },
    conditionals = { italic = true },
    keywords = {},
    functions = {},
    namespaces = { italic = true },
    parameters = { italic = true },
    strings = {},
    variables = {},
  },
  colors = {
    bg0 = "#333333",
    red = "#CB4251",
    aqua = "#0fb9e0",
    lime = "#2ed592",
    green = "#2ed563",
    orange = "#F37A2E",
    yellow = "#EADD61", --"#f0be42",
    blue = "#38D0EF",
    pink = "#f45ab4",
    cyan = "#37c3b5",
    purple = "#be9af7",
  },
  highlights = {
    Comment = { fg = "#6D90A8", fmt = "italic" },
    ["@comment"] = { link = "Comment" },
    PmenuMatch = { bg = "#555555", fg = "#FFB870", fmt = "bold" },
    PmenuMatchSel = { bold = true, sp = "bg0" },
    FloatTitle = { fg = "$red", fmt = "bold" },
    FloatBorder = { fg = "#3B38A0" },
    Type = { fg = "$yellow", fmt = "bold" },
    TablineFill = { fg = "$grey", bg = "bg0" },
    MiniTablineFill = { fg = "$grey", bg = "bg0" },
    MiniTablineHidden = { fg = "$fg", bg = "$bg1" },
    ["@keyword.import"] = { fg = "#2ed592", fmt = "bold" },
    ["@keyword.export"] = { fg = "#2ed592", fmt = "bold" },

    ["@lsp.typemod.enum"] = { fg = "#61AEFF", fmt = "bold" },
    ["@lsp.typemod.enumMember"] = { fg = "#9EC410", fmt = "bold" },
    ["@lsp.typemod.enum.rust"] = { fg = "#61AEFF", fmt = "bold" },
    ["@lsp.typemod.enumMember.rust"] = { fg = "#9EC410", fmt = "bold" },

    ["@lsp.type.modifier"] = { link = "@keyword.modifier" },
    ["@lsp.type.interface"] = { fg = "#D4A017", fmt = "bold,italic" },

    BlinkCmpMenu = { bg = "$bg0" },
    BlinkCmpDoc = { bg = "$bg0" },

    SnacksPickerMatch = { link = "PmenuMatch" },

    BlinkIndentRed = { link = "RainbowDelimiterRed" },
    BlinkIndentOrange = { link = "RainbowDelimiterOrange" },
    BlinkIndentYellow = { link = "RainbowDelimiterYellow" },
    BlinkIndentGreen = { link = "RainbowDelimiterGreen" },
    BlinkIndentCyan = { link = "RainbowDelimiterCyan" },
    BlinkIndentBlue = { link = "RainbowDelimiterBlue" },
    BlinkIndentViolet = { link = "RainbowDelimiterViolet" },

    BlinkIndentRedUnderline = { link = "RainbowDelimiterRed" },
    BlinkIndentOrangeUnderline = { link = "RainbowDelimiterOrange" },
    BlinkIndentYellowUnderline = { link = "RainbowDelimiterYellow" },
    BlinkIndentGreenUnderline = { link = "RainbowDelimiterGreen" },
    BlinkIndentCyanUnderline = { link = "RainbowDelimiterCyan" },
    BlinkIndentBlueUnderline = { link = "RainbowDelimiterBlue" },
    BlinkIndentVioletUnderline = { link = "RainbowDelimiterViolet" },
  },
}
require("bamboo").setup(opts)

-- fluoromachine setup
require("fluoromachine").setup({
  glow = true,
  theme = "fluoromachine",
  transparent = false,
  brightness = 0.05,
})

-- catppuccin setup
require("catppuccin").setup({
  transparent_background = true,
  term_colors = true,
  integrations = {
    aerial = true,
    diffview = true,
    mini = {
      enabled = true,
      indentscope_color = "sky",
    },
    noice = true,
    overseer = true,
    telescope = {
      enabled = true,
      style = "nvchad",
    },
    treesitter = true,
    gitsigns = true,
    flash = true,
    blink_cmp = true,
    mason = true,
    snacks = true,
  },
  highlight_overrides = {
    mocha = function(mocha)
      return {
        CursorLineNr = { fg = mocha.yellow },
        FlashCurrent = { bg = mocha.peach, fg = mocha.base },
        FlashMatch = { bg = mocha.red, fg = mocha.base },
        FlashLabel = { bg = mocha.teal, fg = mocha.base },
        NormalFloat = { bg = mocha.base },
        FloatBorder = { bg = mocha.base },
        FloatTitle = { bg = mocha.base },
        RenderMarkdownCode = { bg = mocha.crust },
        Pmenu = { bg = mocha.base },
      }
    end,
  },
})

local function set_transparent_guides()
  local pmenu_bg = vim.api.nvim_get_hl(0, { name = "Pmenu" }).bg
  local bg_color = pmenu_bg and string.format("#%06x", pmenu_bg) or "#2c3248"
  local ul_color = "#ffff00"

  vim.api.nvim_set_hl(0, "Folded", { bg = "#2c3248", fg = "NONE", italic = true, bold = false })

  -- Darker semi-transparent CursorLine
  vim.api.nvim_set_hl(0, "CursorLine", {
    bg = bg_color or "#1a1b26", -- Darker background color
    blend = 20, -- 0 = opaque, 100 = fully transparent (try 10-30 for subtle effect)
    underdouble = true,
    bold = false,
    sp = ul_color,
  })

  vim.api.nvim_set_hl(0, "CursorLineNr", { bg = "NONE", fg = "#ff9e64", bold = false })
  vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#1f1f1f", fg = "NONE" })
  vim.cmd.hi("Comment gui=none")
  vim.cmd.hi("statusline guibg=NONE")
end

-- Load colorscheme on buffer enter
vim.api.nvim_create_autocmd({ "BufEnter", "BufCreate" }, {
  pattern = "*",
  callback = function()
    vim.cmd("colorscheme bamboo")
    set_transparent_guides()
  end,
})

-- Reapply highlights when colorscheme changes
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    set_transparent_guides()
  end,
})
