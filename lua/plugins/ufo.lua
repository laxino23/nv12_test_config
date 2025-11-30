local map = require("config.keymaps").map

vim.pack.add({
  {
    src = "https://github.com/kevinhwang91/nvim-ufo",
    name = "nvim-ufo",
    version = vim.version.range(">=0.10.0"),
  },
  {
    src = "https://github.com/kevinhwang91/promise-async",
    name = "promise-async",
  },
})

-- 外部 setup 和键映射逻辑
vim.o.foldcolumn = "1"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true

require("ufo").setup({
  preview = {
    mappings = {
      scrollB = "<C-B>",
      scrollF = "<C-F>",
      scrollU = "<C-U>",
      scrollD = "<C-D>",
    },
  },
  provider_selector = function(_, filetype, buftype)
    local function handleFallbackException(bufnr, err, providerName)
      if type(err) == "string" and err:match("UfoFallbackException") then
        return require("ufo").getFolds(bufnr, providerName)
      else
        return require("promise").reject(err)
      end
    end

    return (filetype == "" or buftype == "nofile") and "indent"
      or function(bufnr)
        return require("ufo")
          .getFolds(bufnr, "lsp")
          :catch(function(err)
            return handleFallbackException(bufnr, err, "treesitter")
          end)
          :catch(function(err)
            return handleFallbackException(bufnr, err, "indent")
          end)
      end
  end,
})
local ufo_maps = {
  ["open_all_folds"] = {
    "n",
    "zR",
    function()
      require("ufo").openAllFolds()
    end,
  },
  ["close_all_folds"] = {
    "n",
    "zM",
    function()
      require("ufo").closeAllFolds()
    end,
  },
  ["fold_less"] = {
    "n",
    "zr",
    function()
      require("ufo").openFoldsExceptKinds()
    end,
  },
  ["fold_more"] = {
    "n",
    "zm",
    function()
      require("ufo").closeFoldsWith()
    end,
  },
  ["peek_fold"] = {
    "n",
    "zp",
    function()
      require("ufo").peekFoldedLinesUnderCursor()
    end,
  },
}

map(ufo_maps, { silent = true })
