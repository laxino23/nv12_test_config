vim.pack.add({
  { src = "https://github.com/kevinhwang91/promise-async" },
  { src = "https://github.com/kevinhwang91/nvim-ufo" },
  { src = "https://github.com/luukvbaal/statuscol.nvim" },
})

-- statuscol setup
vim.api.nvim_create_autocmd("BufReadPre", {
  callback = function()
    local builtin = require("statuscol.builtin")
    require("statuscol").setup({
      relculright = true,
      segments = {
        {
          sign = { namespace = { "diagnostic" }, maxwidth = 1, auto = true },
          click = "v:lua.ScSa",
        },
        {
          sign = { name = { ".*" }, maxwidth = 1, colwidth = 1, auto = true },
          click = "v:lua.ScSa",
        },
        { text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
        { text = { builtin.foldfunc, " " }, click = "v:lua.ScFa" },
      },
    })
  end,
})

-- 1. General Options / 通用选项
vim.o.foldcolumn = "1"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true
local icons = require("config.ui").icons.fold
vim.opt.fillchars = {
  foldopen = icons.arrow.open,
  foldclose = icons.arrow.close,
  fold = " ",
  foldsep = " ",
  diff = "/",
  eob = " ",
}
-- Highlights / 高亮设置
vim.api.nvim_set_hl(0, "FoldColumn", { fg = "#6c7086", bg = "NONE" })
vim.api.nvim_set_hl(0, "Folded", { fg = "#a6adc8", bg = "#313244" })
vim.api.nvim_set_hl(0, "UfoCursorFoldedLine", { fg = "#f9e2af", bg = "#45475a", bold = true })

-- virtual text handler
local handler = function(virtText, lnum, endLnum, width, truncate)
  local newVirtText = {}
  local suffix = (" 󰁂 %d "):format(endLnum - lnum)
  local sufWidth = vim.fn.strdisplaywidth(suffix)
  local targetWidth = width - sufWidth
  local curWidth = 0
  for _, chunk in ipairs(virtText) do
    local chunkText = chunk[1]
    local chunkWidth = vim.fn.strdisplaywidth(chunkText)
    if targetWidth > curWidth + chunkWidth then
      table.insert(newVirtText, chunk)
    else
      chunkText = truncate(chunkText, targetWidth - curWidth)
      local hlGroup = chunk[2]
      table.insert(newVirtText, { chunkText, hlGroup })
      chunkWidth = vim.fn.strdisplaywidth(chunkText)
      if curWidth + chunkWidth < targetWidth then
        suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
      end
      break
    end
    curWidth = curWidth + chunkWidth
  end
  table.insert(newVirtText, { suffix, "MoreMsg" })
  return newVirtText
end

local ufo = require("ufo")

ufo.setup({
  provider_selector = function(bufnr, filetype, buftype)
    return { "treesitter", "indent" }
  end,
  open_fold_hl_timeout = 150,
  close_fold_kinds_for_ft = {
    default = { "imports", "comment" },
    json = { "array" },
    c = { "comment", "region" },
  },
  close_fold_current_line_for_ft = {
    default = true,
    c = false,
  },
  preview = {
    win_config = {
      border = "rounded",
      winhighlight = "Normal:Folded",
      winblend = 12,
    },
    mappings = {
      scrollU = "<C-u>",
      scrollD = "<C-d>",
      jumpTop = "[",
      jumpBot = "]",
    },
  },
  fold_virt_text_handler = handler,
})

local ufo_keymaps = {
  -- Basic fold commands / 基础折叠命令
  ["Open-all-folds"] = { "n", "zR", ufo.openAllFolds },
  ["Close-all-folds"] = { "n", "zM", ufo.closeAllFolds },
  ["Open-folds-except-kinds"] = { "n", "zr", ufo.openFoldsExceptKinds },
  ["Close-folds-with"] = { "n", "zm", ufo.closeFoldsWith },

  -- Peek fold logic / 预览折叠逻辑
  ["Peek-folded-lines"] = {
    "n",
    "zK",
    function()
      local winid = ufo.peekFoldedLinesUnderCursor()
      if not winid then
        -- choose one of coc.nvim and nvim lsp
        -- vim.fn.CocActionAsync("definitionHover") -- coc.nvim
        vim.lsp.buf.hover()
      end
    end,
  },
}

local map = require("config.keymaps").map
map(ufo_keymaps, { silent = true })
