-- ============================================================================
-- 按键映射辅助函数 (Keymap Utility Function)
-- ============================================================================
local M = {}
---@param config table<string, table> Key 是描述(desc)，Value 是 { mode, lhs, rhs, ...opts }
---@param opts table|nil 全局选项 (可选, 例如 { silent = true })
local function map(config, opts)
  opts = opts or {}

  for name, map_def in pairs(config) do
    -- 将 key 中的连字符替换为空格作为描述 (例如: "save-file" -> "save file")
    local desc = name:gsub("-", " ")
    local mode = map_def[1]
    local lhs = map_def[2]
    local rhs = map_def[3]

    -- 提取特定选项 (过滤掉数字索引的数组部分，只留 key-value 选项)
    local specific_opts = {}
    for k, v in pairs(map_def) do
      if type(k) ~= "number" then
        specific_opts[k] = v
      end
    end

    -- 合并选项: 全局 Opts -> 特定 Opts -> 描述 Desc
    local final_opts = vim.tbl_deep_extend("force", opts, specific_opts, { desc = desc })
    vim.keymap.set(mode, lhs, rhs, final_opts)
  end
end

-- ============================================================================
-- 基础操作 (Basic Operations)
-- ============================================================================

map({
  ["save"] = { "n", "<leader>ww", ":w<CR>" },
  ["save-and-quit"] = { "n", "<leader>wq", ":wq<CR>" },
  ["just-quit"] = { "n", "<leader>we", ":q<CR>" },
  ["update-and-source"] = { "n", "<leader>o", ":update<CR> :source<CR>" }, -- 保存并重载配置
}, { silent = true })

-- ============================================================================
-- 行移动 (Line Movement - 类似 VSCode)
-- ============================================================================

map({
  -- Visual 模式: 上下移动选中的块
  ["move-selection-down"] = { "v", "<M-Down>", ":m '>+1<CR>gv=gv" },
  ["move-selection-up"] = { "v", "<M-Up>", ":m '<-2<CR>gv=gv" },

  -- Normal 模式: 上下移动单行
  ["move-line-down"] = { "n", "<M-Down>", ":m .+1<CR>==" },
  ["move-line-up"] = { "n", "<M-Up>", ":m .-2<CR>==" },
}, { silent = true })

-- ============================================================================
-- 更好的 j/k 移动 (处理自动换行)
-- ============================================================================

map({
  -- 如果有计数前缀(如 5j)则按物理行移动，否则按视觉行(屏幕行)移动
  ["move-cursor-down"] = { { "n", "x", "v" }, "j", "v:count == 0 ? 'gj' : 'j'" },
  ["move-cursor-up"] = { { "n", "x", "v" }, "k", "v:count == 0 ? 'gk' : 'k'" },
}, { expr = true, silent = true })

-- ============================================================================
-- 注释功能 (Comment Functions)
-- ============================================================================

---在指定位置插入注释
---@param pos "above"|"below"|"end" 插入位置：上方/下方/行尾
local function comment(pos)
  return function()
    local row = vim.api.nvim_win_get_cursor(0)[1]
    local total_lines = vim.api.nvim_buf_line_count(0)
    local commentstring = vim.bo.commentstring
    local cmt = commentstring:gsub("%%s", "") -- 提取注释符号 (如 "-- %s" -> "-- ")
    local index = commentstring:find("%%s")

    local target_line
    if pos == "below" then
      -- 获取下一行的内容作为参考，如果没有下一行则用当前行
      target_line = (row == total_lines) and vim.api.nvim_buf_get_lines(0, row - 1, row, true)[1]
        or vim.api.nvim_buf_get_lines(0, row, row + 1, true)[1]
    else
      target_line = vim.api.nvim_get_current_line()
    end

    if pos == "end" then
      -- 行尾注释: 如果行不为空，先加空格
      if target_line:find("%S") then
        cmt = " " .. cmt
        index = index + 1
      end
      vim.api.nvim_buf_set_lines(0, row - 1, row, false, { target_line .. cmt })
      vim.api.nvim_win_set_cursor(0, { row, #target_line + index - 2 })
    else
      -- 上方/下方注释: 保持与目标行相同的缩进
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

    -- 自动进入插入模式
    vim.api.nvim_feedkeys("a", "n", false)
  end
end

---切换当前行注释，或在空行插入带缩进的注释
local function comment_line()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local line = vim.api.nvim_get_current_line()

  if not line:find("%S") then
    -- 空行: 插入带正确缩进的注释符号
    local commentstring = vim.bo.commentstring
    local cmt = commentstring:gsub("%%s", "")
    local indent_width = vim.fn.indent(row)
    local indent_str = (" "):rep(indent_width)

    vim.api.nvim_buf_set_lines(0, row - 1, row, false, { indent_str .. cmt })
    vim.api.nvim_win_set_cursor(0, { row, #indent_str + #cmt })
    vim.cmd("startinsert!")
  else
    -- 非空行: 使用内置 API 切换注释
    require("vim._comment").toggle_lines(row, row, { row, 0 })
  end
end

---连接行 (Join lines) 并处理计数
local function join_lines()
  local v_count = vim.v.count1 + 1
  local mode = vim.api.nvim_get_mode().mode
  local keys = (mode == "n") and (v_count .. "J") or "J"
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "n", false)
end

map({
  ["comment-line"] = { "n", "gcc", comment_line },
  ["comment-above"] = { "n", "gcO", comment("above") }, -- 在上方插入注释
  ["comment-below"] = { "n", "gco", comment("below") }, -- 在下方插入注释
  ["comment-end"] = { "n", "gcA", comment("end") }, -- 在行尾追加注释
  ["join-lines"] = { { "n", "v" }, "J", join_lines },
}, { silent = true })

-- ============================================================================
-- 插入空行 (Insert Empty Lines)
-- ============================================================================

map({
  ["new-empty-line-below"] = { "n", "<A-o>", "o<Esc>" }, -- Alt+o 下方插入空行不进入编辑模式
  ["new-empty-line-above"] = { "n", "<A-O>", "O<Esc>" }, -- Alt+Shift+o 上方插入空行
}, { silent = true })

-- ============================================================================
-- 复制操作 (Yank Operations)
-- ============================================================================

-- 复制整个缓冲区内容
local function yank_all()
  vim.cmd("normal! gg0yG")
end

map({
  ["yank-all"] = { "n", "<leader>ya", yank_all },
}, { silent = true })

-- ============================================================================
-- 更好的粘贴 (Better Paste)
-- ============================================================================

map({
  -- Visual 模式粘贴时不复制被替换的文本 (保持寄存器内容)
  ["paste-without-yank"] = { "x", "p", '"_dP' },
  ["delete-without-yank"] = { { "n", "v" }, "D", '"_d' }, -- 删除但不存入剪贴板
}, { silent = true })

-- ============================================================================
-- 窗口导航 (Window Navigation)
-- ============================================================================

map({
  ["window-left"] = { "n", "<C-h>", "<C-w>h" },
  ["window-down"] = { "n", "<C-j>", "<C-w>j" },
  ["window-up"] = { "n", "<C-k>", "<C-w>k" },
  ["window-right"] = { "n", "<C-l>", "<C-w>l" },
}, { silent = true })

-- ============================================================================
-- 窗口分裂 (Window Split)
-- ============================================================================

map({
  ["split-vertically"] = { { "n", "v" }, "<leader>sv", ":vsplit<CR>" },
  ["split-horizontally"] = { { "n", "v" }, "<leader>sh", ":split<CR>" },
}, { silent = true })

-- ============================================================================
-- 窗口大小调整 (Window Resizing)
-- ============================================================================

map({
  ["resize-left"] = { "n", "<C-Left>", ":vertical resize -2<CR>" },
  ["resize-right"] = { "n", "<C-Right>", ":vertical resize +2<CR>" },
  ["resize-up"] = { "n", "<C-Up>", ":resize +2<CR>" },
  ["resize-down"] = { "n", "<C-Down>", ":resize -2<CR>" },
}, { silent = true })

-- ============================================================================
-- 缓冲区导航 (Buffer Navigation)
-- ============================================================================

map({
  ["next-buffer"] = { "n", "<leader>bl", ":bnext<CR>" },
  ["prev-buffer"] = { "n", "<leader>bh", ":bprevious<CR>" },
  ["close-buffer"] = { "n", "<leader>bc", ":bdelete<CR>" },
}, { silent = true })

-- ============================================================================
-- 更好的缩进 (Better Indenting)
-- ============================================================================

map({
  -- 缩进后保持选中状态，方便连续缩进
  ["indent-left"] = { "v", "<", "<gv" },
  ["indent-right"] = { "v", ">", ">gv" },
}, { silent = true })

-- ============================================================================
-- 搜索与替换 (Search and Replace)
-- ============================================================================

map({
  ["clear-search-highlight"] = { "n", "<Esc>", ":noh<CR>" }, -- Esc 清除高亮
  ["search-and-replace"] = { "n", "<leader>sr", ":%s//g<Left><Left>" }, -- 全局替换
  ["search-and-replace-word"] = { "n", "<leader>sw", ":%s/<C-r><C-w>//g<Left><Left>" }, -- 替换光标下的词
}, { silent = false }) -- 不静默，以便看到命令行输入

-- ============================================================================
-- 快速导航 (Quick Navigation)
-- ============================================================================

map({
  -- H 和 L 快速移动到行首和行尾
  ["start-of-line"] = { { "n", "v" }, "H", "^" },
  ["end-of-line"] = { { "n", "v" }, "L", "$" },
}, { silent = true })

-- ============================================================================
-- 跳转后居中屏幕 (Center Screen After Jumps)
-- ============================================================================

map({
  ["next-search-centered"] = { "n", "n", "nzzzv" }, -- 搜索下一个并居中
  ["prev-search-centered"] = { "n", "N", "Nzzzv" }, -- 搜索上一个并居中
  ["half-page-down-centered"] = { "n", "<C-d>", "<C-d>zz" }, -- 翻半页并居中
  ["half-page-up-centered"] = { "n", "<C-u>", "<C-u>zz" },
}, { silent = true })

-- ============================================================================
-- Quick Fix 和 Location List
-- ============================================================================

map({
  ["quickfix-next"] = { "n", "]q", ":cnext<CR>" },
  ["quickfix-prev"] = { "n", "[q", ":cprev<CR>" },
  ["location-next"] = { "n", "]l", ":lnext<CR>" },
  ["location-prev"] = { "n", "[l", ":lprev<CR>" },
}, { silent = true })

-- ============================================================================
-- 终端模式 (Terminal Mode)
-- ============================================================================

map({
  ["terminal-escape"] = { "t", "<Esc>", "<C-\\><C-n>" }, -- Esc 退出终端插入模式
  ["terminal-window-left"] = { "t", "<C-h>", "<C-\\><C-n><C-w>h" }, -- 终端内直接切窗口
  ["terminal-window-down"] = { "t", "<C-j>", "<C-\\><C-n><C-w>j" },
  ["terminal-window-up"] = { "t", "<C-k>", "<C-\\><C-n><C-w>k" },
  ["terminal-window-right"] = { "t", "<C-l>", "<C-\\><C-n><C-w>l" },
}, { silent = true })

-- ============================================================================
-- 其他自定义 (Other Customized)
-- ============================================================================

-- 自定义撤销 (Undo)
local function undo()
  local mode = vim.api.nvim_get_mode().mode
  if mode == "n" or mode == "i" or mode == "v" then
    vim.cmd("undo")
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
  end
end
-- 自定义重做 (Redo)
local function redo()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
  vim.cmd("redo")
end

-- disable undo
vim.keymap.set("n", "u", "<Nop>", { noremap = true, silent = true })
map({
  ["undo"] = { { "n", "i", "v", "t", "c" }, "<C-z>", undo },
  ["redo"] = { { "n", "i", "v", "t", "c" }, "<C-r>", redo },
  -- ["redo"] = { { "n", "i", "v", "t", "c" }, "<C-S-z>", redo },
}, { silent = true })

-- 左右选择移动
map({
  ["left-arrow-visual-select"] = { "n", "<Left>", "vh" },
  ["right-arrow-visual-select"] = { "n", "<Right>", "vl" },
}, { silent = true })

-- 隔行插入
---@param direction "up"|"down"
local function insert_lines(direction)
  local line = vim.api.nvim_get_current_line()
  local indent = line:match("^%s*") or ""
  local lines = { "", "", "" } -- 插入3个空行
  -- 获取当前光标位置（row 是 1-based）
  local row = vim.api.nvim_win_get_cursor(0)[1]
  if direction == "up" then
    -- 在当前行上方插入 (索引 row-1)
    vim.api.nvim_buf_set_lines(0, row - 1, row - 1, false, lines)
    -- 光标移动到新插入区域的中间行
    vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
  else
    -- 在当前行下方插入 (索引 row)
    vim.api.nvim_buf_set_lines(0, row, row, false, lines)
    -- 光标移动到新插入区域的中间行
    vim.api.nvim_win_set_cursor(0, { row + 2, 0 })
  end
  -- 进入插入模式并应用缩进
  vim.cmd("startinsert")
  if #indent > 0 then
    vim.api.nvim_put({ indent }, "c", false, true)
  end
end

map({
  ["insert-above-three-lines"] = {
    "n",
    "<leader>op",
    function()
      insert_lines("up")
    end,
  },
  ["insert-below-three-lines"] = {
    "n",
    "<leader>oo",
    function()
      insert_lines("down")
    end,
  },
}, { silent = true })
M.map = map
return M
