-- Import map helper at the top (Required for Multicursor)
-- 导入 map 辅助函数 (Multicursor 需要)
local map = require("config.keymaps").map

-- ============================================================================
-- Mini.ai (Text Objects)
-- ============================================================================
local ai = require("mini.ai")
ai.setup({
  custom_textobjects = {
    ["?"] = false,
    ["/"] = ai.gen_spec.user_prompt(),
    ["%"] = function()
      local from = { line = 1, col = 1 }
      local to = { line = vim.fn.line("$"), col = math.max(vim.fn.getline("$"):len(), 1) }
      return { from = from, to = to }
    end,
    a = ai.gen_spec.treesitter({ a = "@parameter.outer", i = "@parameter.inner" }),
    c = ai.gen_spec.treesitter({ a = "@comment.outer", i = "@comment.inner" }),
    f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
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
  mappings = { around = "a", inside = "i" },
  n_lines = 500,
})

-- ============================================================================
-- Mini.surround & Splitjoin
-- ============================================================================
require("mini.surround").setup({
  mappings = { add = "gsa", delete = "gsd", replace = "gsr" },
})

require("mini.splitjoin").setup({
  mappings = { toggle = "gS" },
})

-- ============================================================================
-- Autopairs
-- ============================================================================
local npairs = require("nvim-autopairs")
local Rule = require("nvim-autopairs.rule")
local cond = require("nvim-autopairs.conds")
local ts_conds = require("nvim-autopairs.ts-conds")

npairs.setup({
  check_ts = true,
  map_bs = false,
  ts_config = { lua = { "string" }, javascript = { "template_string" } },
  fast_wrap = {
    map = "<M-e>",
    chars = { "{", "[", "(", '"', "'" },
    pattern = [=[[%'%"%)%>%]%)%}%,]]=],
    offset = 0,
    end_key = "$",
    keys = "qwertyuiopzxcvbnmasdfghjkl",
    check_comma = true,
    highlight = "Search",
    highlight_grey = "Comment",
  },
})

local brackets = { { "(", ")" }, { "[", "]" }, { "{", "}" } }

npairs.add_rules({
  Rule(" ", " ", "-markdown")
    :with_pair(function(opts)
      local pair = opts.line:sub(opts.col - 1, opts.col)
      return vim.tbl_contains({
        brackets[1][1] .. brackets[1][2],
        brackets[2][1] .. brackets[2][2],
        brackets[3][1] .. brackets[3][2],
      }, pair)
    end)
    :with_move(cond.none())
    :with_cr(cond.none())
    :with_del(function(opts)
      local col = vim.api.nvim_win_get_cursor(0)[2]
      local context = opts.line:sub(col - 1, col + 2)
      return vim.tbl_contains({
        brackets[1][1] .. "  " .. brackets[1][2],
        brackets[2][1] .. "  " .. brackets[2][2],
        brackets[3][1] .. "  " .. brackets[3][2],
      }, context)
    end),
})

for _, bracket in pairs(brackets) do
  npairs.add_rules({
    Rule(bracket[1] .. " ", " " .. bracket[2])
      :with_pair(function()
        return false
      end)
      :with_del(function()
        return false
      end)
      :with_move(function(opts)
        return opts.prev_char:match(".%" .. bracket[2]) ~= nil
      end)
      :use_key(bracket[2]),
    Rule(bracket[1], bracket[2]):with_pair(cond.after_text("$")),
    Rule(bracket[1] .. bracket[2], ""):with_pair(function()
      return false
    end):with_cr(function()
      return false
    end),
  })
end

npairs.add_rule(Rule("$", "$", "markdown")
  :with_move(function(opts)
    return opts.next_char == opts.char
      and ts_conds.is_ts_node({ "inline_formula", "displayed_equation", "math_environment" })(opts)
  end)
  :with_pair(
    ts_conds.is_not_ts_node({ "inline_formula", "displayed_equation", "math_environment" })
  )
  :with_pair(cond.not_before_text("\\")))

npairs.add_rule(
  Rule("/**", " */"):with_pair(cond.not_after_regex(".-%*/", -1)):set_end_pair_length(3)
)
npairs.add_rule(Rule("**", "**", "markdown"):with_move(function(opts)
  return cond.after_text("*")(opts) and cond.not_before_text("\\")(opts)
end))
npairs.add_rules({
  Rule("%(.*%)%s*%=>$", " {  }", { "typescript", "typescriptreact", "javascript" })
    :use_regex(true)
    :set_end_pair_length(2),
})

-- ============================================================================
-- Lazy Load Editing Tools
-- ============================================================================
local lazy_group = vim.api.nvim_create_augroup("ConfigLazyEditing", { clear = true })

require("nvim-ts-autotag").setup({})

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  group = lazy_group,
  once = true,
  callback = function()
    require("ts-comments").setup({})
  end,
})

-- ============================================================================
-- Multicursor.nvim
-- ============================================================================
local status, mc = pcall(require, "multicursor-nvim")
if status then
  mc.setup()

  -- Keymaps
  map({
    -- Base Operations
    ["multicursor-add-cursor"] = { { "n", "x" }, "mm", mc.addCursor },
    ["multicursor-toggle"] = { { "n", "x" }, "<leader>up", mc.toggleCursor },

    -- Line Operations (Add)
    ["multicursor-add-up"] = {
      { "n", "x" },
      "<up>",
      function()
        mc.lineAddCursor(-1)
      end,
    },
    ["multicursor-add-down"] = {
      { "n", "x" },
      "<down>",
      function()
        mc.lineAddCursor(1)
      end,
    },

    -- Line Operations (Skip)
    ["multicursor-skip-up"] = {
      { "n", "x" },
      "<leader><up>",
      function()
        mc.lineSkipCursor(-1)
      end,
    },
    ["multicursor-skip-down"] = {
      { "n", "x" },
      "<leader><down>",
      function()
        mc.lineSkipCursor(1)
      end,
    },

    -- Match Operations
    ["multicursor-match-next"] = {
      { "n", "x" },
      "<C-d>",
      function()
        mc.matchAddCursor(1)
      end,
    },
    ["multicursor-match-prev"] = {
      { "n", "x" },
      "<C-u>",
      function()
        mc.matchAddCursor(-1)
      end,
    },

    -- Mouse Operations
    ["multicursor-mouse-click"] = { "n", "<c-leftmouse>", mc.handleMouse },
    ["multicursor-mouse-drag"] = { "n", "<c-leftdrag>", mc.handleMouseDrag },
    ["multicursor-mouse-release"] = { "n", "<c-leftrelease>", mc.handleMouseRelease },
  })

  -- Layers (Modes)
  mc.addKeymapLayer(function(layerSet)
    layerSet({ "n", "x" }, "[p", mc.prevCursor)
    layerSet({ "n", "x" }, "]p", mc.nextCursor)
    layerSet("n", "<esc>", function()
      if not mc.cursorsEnabled() then
        mc.enableCursors()
      else
        mc.clearCursors()
      end
    end)
  end)

  -- Highlights
  local hl = vim.api.nvim_set_hl
  hl(0, "MultiCursorCursor", { reverse = true })
  hl(0, "MultiCursorVisual", { link = "Visual" })
  hl(0, "MultiCursorSign", { link = "SignColumn" })
  hl(0, "MultiCursorMatchPreview", { link = "IncSearch" })
  hl(0, "MultiCursorDisabledCursor", { reverse = true })
  hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
end
