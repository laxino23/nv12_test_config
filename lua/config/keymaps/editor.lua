return function(map)
  -- =============================================================================
  -- Keymaps: Terminal / 映射：终端
  -- =============================================================================

  map({
    ["terminal-escape"] = { "t", "<Esc>", "<C-\\><C-n>" },
    ["terminal-window-left"] = { "t", "<C-h>", "<C-\\><C-n><C-w>h" },
    ["terminal-window-down"] = { "t", "<C-j>", "<C-\\><C-n><C-w>j" },
    ["terminal-window-up"] = { "t", "<C-k>", "<C-\\><C-n><C-w>k" },
    ["terminal-window-right"] = { "t", "<C-l>", "<C-\\><C-n><C-w>l" },
  }, { silent = true })
end
