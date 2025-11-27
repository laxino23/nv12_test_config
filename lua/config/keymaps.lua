-- ============================================================================
-- Keymap Utility Function
-- ============================================================================

---@param config table<string, table> Key is the desc, Value is { mode, lhs, rhs, ...opts }
---@param opts table|nil Global options (optional, e.g., { silent = true })
local function map(config, opts)
  opts = opts or {}

  for name, map_def in pairs(config) do
    local desc = name:gsub("-", " ")
    local mode = map_def[1]
    local lhs = map_def[2]
    local rhs = map_def[3]

    -- Extract specific options (filter out numeric indices)
    local specific_opts = {}
    for k, v in pairs(map_def) do
      if type(k) ~= "number" then
        specific_opts[k] = v
      end
    end

    -- Merge: Global Opts -> Specific Opts -> Description
    local final_opts = vim.tbl_deep_extend("force", opts, specific_opts, { desc = desc })
    vim.keymap.set(mode, lhs, rhs, final_opts)
  end
end

-- ============================================================================
-- Basic Operations
-- ============================================================================

map({
  ["save"] = { "n", "<leader>ww", ":w<CR>" },
  ["quit"] = { "n", "<leader>qa", ":q<CR>" },
  ["save-and-quit"] = { "n", "<leader>wq", ":wq<CR>" },
  ["update-and-source"] = { "n", "<leader>o", ":update<CR> :source<CR>" },
}, { silent = true })

-- ============================================================================
-- Line Movement
-- ============================================================================

map({
  -- Visual Mode: Move selected block up/down
  ["move-selection-down"] = { "v", "<M-Down>", ":m '>+1<CR>gv=gv" },
  ["move-selection-up"] = { "v", "<M-Up>", ":m '<-2<CR>gv=gv" },

  -- Normal Mode: Move single line up/down
  ["move-line-down"] = { "n", "<M-Down>", ":m .+1<CR>==" },
  ["move-line-up"] = { "n", "<M-Up>", ":m .-2<CR>==" },
}, { silent = true })

-- ============================================================================
-- Better j/k Movement (Visual Lines)
-- ============================================================================

map({
  ["move-cursor-down"] = { { "n", "x", "v" }, "j", "v:count == 0 ? 'gj' : 'j'" },
  ["move-cursor-up"] = { { "n", "x", "v" }, "k", "v:count == 0 ? 'gk' : 'k'" },
}, { expr = true, silent = true })

-- ============================================================================
-- Comment Functions
-- ============================================================================

---Insert a comment at the specified position
---@param pos "above"|"below"|"end" Where to insert the comment
local function comment(pos)
  return function()
    local row = vim.api.nvim_win_get_cursor(0)[1]
    local total_lines = vim.api.nvim_buf_line_count(0)
    local commentstring = vim.bo.commentstring
    local cmt = commentstring:gsub("%%s", "")
    local index = commentstring:find("%%s")

    local target_line
    if pos == "below" then
      target_line = (row == total_lines) and vim.api.nvim_buf_get_lines(0, row - 1, row, true)[1]
        or vim.api.nvim_buf_get_lines(0, row, row + 1, true)[1]
    else
      target_line = vim.api.nvim_get_current_line()
    end

    if pos == "end" then
      -- Add space before comment if line is non-blank
      if target_line:find("%S") then
        cmt = " " .. cmt
        index = index + 1
      end
      vim.api.nvim_buf_set_lines(0, row - 1, row, false, { target_line .. cmt })
      vim.api.nvim_win_set_cursor(0, { row, #target_line + index - 2 })
    else
      -- Get indentation from target line
      local line_start = target_line:find("%S") or (#target_line + 1)
      local indent = target_line:sub(1, line_start - 1)

      if pos == "above" then
        vim.api.nvim_buf_set_lines(0, row - 1, row - 1, true, { indent .. cmt })
        vim.api.nvim_win_set_cursor(0, { row, #indent + index - 2 })
      elseif pos == "below" then
        vim.api.nvim_buf_set_lines(0, row, row, true, { indent .. cmt })
        vim.api.nvim_win_set_cursor(0, { row + 1, #indent + index - 2 })
      end
    end

    vim.api.nvim_feedkeys("a", "n", false)
  end
end

---Toggle comment on current line or start insert mode with comment on blank line
local function comment_line()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local line = vim.api.nvim_get_current_line()

  if not line:find("%S") then
    -- Blank line: insert comment with proper indentation
    local commentstring = vim.bo.commentstring
    local cmt = commentstring:gsub("%%s", "")
    local indent_width = vim.fn.indent(row)
    local indent_str = (" "):rep(indent_width)

    vim.api.nvim_buf_set_lines(0, row - 1, row, false, { indent_str .. cmt })
    vim.api.nvim_win_set_cursor(0, { row, #indent_str + #cmt })
    vim.cmd("startinsert!")
  else
    -- Non-blank line: toggle comment
    require("vim._comment").toggle_lines(row, row, { row, 0 })
  end
end

---Join lines with proper count handling
local function join_lines()
  local v_count = vim.v.count1 + 1
  local mode = vim.api.nvim_get_mode().mode
  local keys = (mode == "n") and (v_count .. "J") or "J"
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "n", false)
end

map({
  ["comment-line"] = { "n", "gcc", comment_line },
  ["comment-above"] = { "n", "gcO", comment("above") },
  ["comment-below"] = { "n", "gco", comment("below") },
  ["comment-end"] = { "n", "gcA", comment("end") },
  ["join-lines"] = { { "n", "v" }, "J", join_lines },
}, { silent = true })

-- ============================================================================
-- Insert Empty Lines
-- ============================================================================

map({
  ["new-empty-line-below"] = { "n", "<A-o>", "o<Esc>" },
  ["new-empty-line-above"] = { "n", "<A-O>", "O<Esc>" },
}, { silent = true })

-- ============================================================================
-- Yank Operations
-- ============================================================================

-- Yank entire buffer content
local function yank_all()
  vim.cmd("normal! gg0yG")
end

map({
  ["yank-all"] = { "n", "<leader>ya", yank_all },
}, { silent = true })

-- ============================================================================
-- Better Paste
-- ============================================================================

map({
  -- Paste without yanking replaced text in visual mode
  ["paste-without-yank"] = { "x", "p", '"_dP' },
  ["delete-without-yank"] = { { "n", "v" }, "D", '"_d' },
}, { silent = true })

-- ============================================================================
-- Window Navigation
-- ============================================================================

map({
  ["window-left"] = { "n", "<C-h>", "<C-w>h" },
  ["window-down"] = { "n", "<C-j>", "<C-w>j" },
  ["window-up"] = { "n", "<C-k>", "<C-w>k" },
  ["window-right"] = { "n", "<C-l>", "<C-w>l" },
}, { silent = true })

-- ============================================================================
-- Window Resizing
-- ============================================================================

map({
  ["resize-left"] = { "n", "<C-Left>", ":vertical resize -2<CR>" },
  ["resize-right"] = { "n", "<C-Right>", ":vertical resize +2<CR>" },
  ["resize-up"] = { "n", "<C-Up>", ":resize +2<CR>" },
  ["resize-down"] = { "n", "<C-Down>", ":resize -2<CR>" },
}, { silent = true })

-- ============================================================================
-- Buffer Navigation
-- ============================================================================

map({
  ["next-buffer"] = { "n", "<leader>bl", ":bnext<CR>" },
  ["prev-buffer"] = { "n", "<leader>bh", ":bprevious<CR>" },
  ["close-buffer"] = { "n", "<leader>bc", ":bdelete<CR>" },
}, { silent = true })

-- ============================================================================
-- Better Indenting
-- ============================================================================

map({
  ["indent-left"] = { "v", "<", "<gv" },
  ["indent-right"] = { "v", ">", ">gv" },
}, { silent = true })

-- ============================================================================
-- Search and Replace
-- ============================================================================

map({
  ["clear-search-highlight"] = { "n", "<Esc>", ":noh<CR>" },
  ["search-and-replace"] = { "n", "<leader>sr", ":%s//g<Left><Left>" },
  ["search-and-replace-word"] = { "n", "<leader>sw", ":%s/<C-r><C-w>//g<Left><Left>" },
}, { silent = false }) -- Not silent so you can see the command

-- ============================================================================
-- Quick Navigation
-- ============================================================================

map({
  ["start-of-line"] = { { "n", "v" }, "H", "^" },
  ["end-of-line"] = { { "n", "v" }, "L", "$" },
}, { silent = true })

-- ============================================================================
-- Center Screen After Jumps
-- ============================================================================

map({
  ["next-search-centered"] = { "n", "n", "nzzzv" },
  ["prev-search-centered"] = { "n", "N", "Nzzzv" },
  ["half-page-down-centered"] = { "n", "<C-d>", "<C-d>zz" },
  ["half-page-up-centered"] = { "n", "<C-u>", "<C-u>zz" },
}, { silent = true })

-- ============================================================================
-- Quick Fix and Location List
-- ============================================================================

map({
  ["quickfix-next"] = { "n", "]q", ":cnext<CR>" },
  ["quickfix-prev"] = { "n", "[q", ":cprev<CR>" },
  ["location-next"] = { "n", "]l", ":lnext<CR>" },
  ["location-prev"] = { "n", "[l", ":lprev<CR>" },
}, { silent = true })

-- ============================================================================
-- Terminal Mode
-- ============================================================================

map({
  ["terminal-escape"] = { "t", "<Esc>", "<C-\\><C-n>" },
  ["terminal-window-left"] = { "t", "<C-h>", "<C-\\><C-n><C-w>h" },
  ["terminal-window-down"] = { "t", "<C-j>", "<C-\\><C-n><C-w>j" },
  ["terminal-window-up"] = { "t", "<C-k>", "<C-\\><C-n><C-w>k" },
  ["terminal-window-right"] = { "t", "<C-l>", "<C-\\><C-n><C-w>l" },
}, { silent = true })

-- ============================================================================
-- Other Customized
-- ============================================================================
map({
  -- line lead and trail
  ["to-line-front-with-word"] = { { "n", "v" }, "H", "^" },
  ["to-line-end"] = { { "n", "v" }, "L", "$" },
}, { silent = true })

function format()
  require("conform").format({
    async = true,
    lsp_fallback = true,
  })
end
map({ ["format-current-buffer"] = { "n", "<leader>lf", format } }, { silent = true })

local function undo()
  local mode = vim.api.nvim_get_mode().mode
  if mode == "n" or mode == "i" or mode == "v" then
    vim.cmd("undo")
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
  end
end

map({ ["undo"] = { { "n", "i", "v", "t", "c" }, "<C-z>", undo } }, { silent = true })

return { map = map }
