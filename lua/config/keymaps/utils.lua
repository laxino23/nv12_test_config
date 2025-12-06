local M = {}

-- =============================================================================
-- Keymap Utility / 按键映射工具
-- =============================================================================

---Batch register key mappings from a configuration table.
---批量注册配置表中的按键映射。
---@param config table<string, table>
---@param opts table|nil
M.map = function(config, opts)
  opts = opts or {}

  for name, map_def in pairs(config) do
    -- Replace hyphens with spaces for description
    local desc = name:gsub("-", " ")
    local mode = map_def[1]
    local lhs = map_def[2]
    local rhs = map_def[3]

    local specific_opts = {}
    for k, v in pairs(map_def) do
      if type(k) ~= "number" then
        specific_opts[k] = v
      end
    end

    local final_opts = vim.tbl_deep_extend("force", opts, specific_opts, { desc = desc })
    vim.keymap.set(mode, lhs, rhs, final_opts)
  end
end

-- =============================================================================
-- Line & Fold Movement / 行与折叠移动
-- =============================================================================

M.lineMovement = {}

-- Get visual selection range including folds
-- 获取包含折叠的视觉选区范围
local function get_visual_unit(line_num)
  local fold_start = vim.fn.foldclosed(line_num)
  if fold_start ~= -1 then
    return fold_start, vim.fn.foldclosedend(line_num)
  else
    return line_num, line_num
  end
end

M.lineMovement.move_normal_line_v = function(direction)
  local cur = vim.fn.line(".")
  local start_line, end_line
  local fold_start = vim.fn.foldclosed(cur)

  if fold_start ~= -1 then
    start_line = fold_start
    end_line = vim.fn.foldclosedend(cur)
  else
    start_line = cur
    end_line = cur
  end

  if direction == "down" then
    if end_line == vim.fn.line("$") then
      return
    end
    local next_line = end_line + 1
    local next_start = vim.fn.foldclosed(next_line)
    local next_end = (next_start ~= -1) and vim.fn.foldclosedend(next_line) or next_line
    vim.cmd(start_line .. "," .. end_line .. "m " .. next_end)
    vim.cmd(start_line .. "," .. end_line .. "=")
    local adjust = next_end - end_line
    vim.fn.cursor(cur + adjust, vim.fn.col("."))
  elseif direction == "up" then
    if start_line == 1 then
      return
    end
    local prev_line = start_line - 1
    local prev_start_fold = vim.fn.foldclosed(prev_line)
    local prev_start = (prev_start_fold ~= -1) and prev_start_fold or prev_line

    -- Calculate destination: prev_start - 1, ensuring it's >= 0
    local dest = math.max(0, prev_start - 1)
    vim.cmd(start_line .. "," .. end_line .. "m " .. dest)

    local new_start = prev_start
    local new_end = new_start + (end_line - start_line)
    vim.cmd(new_start .. "," .. new_end .. "=")

    local adjust = start_line - prev_start
    vim.fn.cursor(cur - adjust, vim.fn.col("."))
  end
end
M.lineMovement.move_visual_line_v = function(direction)
  vim.cmd("normal! \27") -- Exit visual mode to get marks
  local s_start = vim.fn.line("'<")
  local s_end = vim.fn.line("'>")
  local total_lines = vim.api.nvim_buf_line_count(0)
  local new_start, new_end

  if direction == "down" then
    local target_line_idx = s_end + 1
    if target_line_idx > total_lines then
      vim.cmd("normal! gv")
      return
    end
    local t_start, t_end = get_visual_unit(target_line_idx)
    local offset = t_end - t_start + 1

    vim.cmd(string.format("%d,%d move %d", s_start, s_end, t_end))
    new_start = s_start + offset
    new_end = s_end + offset
  elseif direction == "up" then
    local target_line_idx = s_start - 1
    if target_line_idx < 1 then
      vim.cmd("normal! gv")
      return
    end
    local t_start, t_end = get_visual_unit(target_line_idx)
    local offset = t_end - t_start + 1

    vim.cmd(string.format("%d,%d move %d", s_start, s_end, t_start - 1))
    new_start = s_start - offset
    new_end = s_end - offset
  end

  vim.api.nvim_win_set_cursor(0, { new_start, 0 })
  vim.cmd("normal! V")
  if new_end > new_start then
    vim.cmd("normal! " .. new_end .. "G")
  end
end

M.lineMovement.move_visual_word_h = function(direction)
  -- Exit visual mode to capture marks
  vim.cmd("normal! \27")

  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local start_line = start_pos[2]
  local start_col = start_pos[3]
  local end_col = end_pos[3]

  -- Only support single-line horizontal movement
  if start_line ~= end_pos[2] then
    vim.cmd("normal! gv")
    return
  end

  local line = vim.fn.getline(start_line)
  local line_len = #line

  if direction == "left" then
    -- Can't move if at start of line
    if start_col <= 1 then
      vim.cmd("normal! gv")
      return
    end

    -- Get selected text
    local selected_text = line:sub(start_col, end_col)

    -- Get char before selection
    local char_before = line:sub(start_col - 1, start_col - 1)

    -- Build new line: before selection (minus 1 char) + char_before + selected_text + after selection
    local before = line:sub(1, start_col - 2)
    local after = line:sub(end_col + 1)
    local new_line = before .. selected_text .. char_before .. after

    -- Set the new line
    vim.fn.setline(start_line, new_line)

    -- Reselect at new position
    local new_start_col = start_col - 1
    local new_end_col = end_col - 1

    vim.fn.setpos("'<", { 0, start_line, new_start_col, 0 })
    vim.fn.setpos("'>", { 0, start_line, new_end_col, 0 })
    vim.cmd("normal! gv")
  elseif direction == "right" then
    -- Can't move if at end of line
    if end_col >= line_len then
      vim.cmd("normal! gv")
      return
    end

    -- Get selected text
    local selected_text = line:sub(start_col, end_col)

    -- Get char after selection
    local char_after = line:sub(end_col + 1, end_col + 1)

    -- Build new line: before + char_after + selected_text + after selection
    local before = line:sub(1, start_col - 1)
    local after = line:sub(end_col + 2)
    local new_line = before .. char_after .. selected_text .. after

    -- Set the new line
    vim.fn.setline(start_line, new_line)

    -- Reselect at new position
    local new_start_col = start_col + 1
    local new_end_col = end_col + 1

    vim.fn.setpos("'<", { 0, start_line, new_start_col, 0 })
    vim.fn.setpos("'>", { 0, start_line, new_end_col, 0 })
    vim.cmd("normal! gv")
  end
end
M.lineMovement.move_normal_word_h = function(direction)
  -- Select word under cursor (inner word)
  vim.cmd("normal! viw")

  -- Now move the selection
  M.lineMovement.move_visual_word_h(direction)
end

-- =============================================================================
-- Commenting / 注释功能
-- =============================================================================

M.comment = {}

-- Insert comment at specific position
-- 在指定位置（上方/下方/行尾）插入注释
M.comment.comment = function(pos)
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
      if target_line:find("%S") then
        cmt = " " .. cmt
        index = index + 1
      end
      vim.api.nvim_buf_set_lines(0, row - 1, row, false, { target_line .. cmt })
      vim.api.nvim_win_set_cursor(0, { row, #target_line + index - 2 })
    else
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

-- Toggle single line comment (Handles empty lines)
-- 切换单行注释（特殊处理空行）
M.comment.comment_line = function()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local line = vim.api.nvim_get_current_line()
  if not line:find("%S") then
    local commentstring = vim.bo.commentstring
    local cmt = commentstring:gsub("%%s", "")
    local indent_width = vim.fn.indent(row)
    local indent_str = (" "):rep(indent_width)
    vim.api.nvim_buf_set_lines(0, row - 1, row, false, { indent_str .. cmt })
    vim.api.nvim_win_set_cursor(0, { row, #indent_str + #cmt })
    vim.cmd("startinsert!")
  else
    require("vim._comment").toggle_lines(row, row, { row, 0 })
  end
end

-- Toggle comment for line or fold (Simplified logic)
-- 切换行或折叠的注释状态（简化逻辑）
M.comment.toggle_fold_or_line = function()
  local current_line = vim.fn.line(".")
  local fold_start = vim.fn.foldclosed(current_line)

  -- === CASE 1: Not in a fold - handle as regular line ===
  if fold_start == -1 then
    M.comment.comment_line()
    return
  end

  -- === CASE 2: In a closed fold ===
  local fold_end = vim.fn.foldclosedend(current_line)
  local filetype = vim.bo.filetype

  -- Get fold text utilities
  local fold_utils = require("plugins.folding.utils")

  -- Open fold to inspect
  vim.cmd("normal! zo")

  -- Get comment string from vim's commentstring option
  local line_comment = vim.bo.commentstring:gsub("%%s.*", ""):gsub("%s+$", "")

  -- Get patterns for this filetype
  local line_pattern = fold_utils.comment_type.filetype_comment_patterns[filetype]
  local lsp_pattern = fold_utils.comment_type.lsp_annotation_patterns[filetype]

  -- Fallback: if no pattern defined for this filetype, use a generic pattern
  if not line_pattern then
    -- Extract comment chars from commentstring and escape them for pattern matching
    local comment_chars = line_comment:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
    line_pattern = "^%s*" .. comment_chars
  end

  -- Check if ALL non-LSP lines have comment markers
  local has_uncommented = false
  for i = fold_start, fold_end do
    local line = vim.fn.getline(i)

    -- Skip LSP annotations by inverting logic
    if not (lsp_pattern and line:match(lsp_pattern)) then
      -- Check if this line doesn't have a comment marker
      if not line:match(line_pattern) then
        has_uncommented = true
        break
      end
    end
  end

  if has_uncommented then
    -- === Add comment markers to ALL lines (except LSP annotations) ===
    for i = fold_start, fold_end do
      local line = vim.fn.getline(i)

      -- Process only if not LSP annotation
      if not (lsp_pattern and line:match(lsp_pattern)) then
        -- Add comment marker (preserve indentation)
        local indent = line:match("^%s*") or ""
        local content = line:sub(#indent + 1)

        -- Don't add space after comment if line is empty or only has whitespace
        local new_line
        if content == "" or content:match("^%s*$") then
          new_line = indent .. line_comment
        else
          new_line = indent .. line_comment .. " " .. content
        end
        vim.fn.setline(i, new_line)
      end
    end

    -- After commenting, close the fold
    vim.fn.cursor(fold_start, 1)
    vim.cmd("normal! zc")
  else
    -- === Remove comment markers from ALL lines (except LSP annotations) ===
    for i = fold_start, fold_end do
      local line = vim.fn.getline(i)

      -- Process only if not LSP annotation
      if not (lsp_pattern and line:match(lsp_pattern)) then
        -- Remove comment marker if present
        if line:match(line_pattern) then
          local new_line = line:gsub(line_pattern .. "%s?", "", 1)
          vim.fn.setline(i, new_line)
        end
      end
    end

    -- Format the range to help treesitter recognize it as code
    vim.cmd(string.format("silent! %d,%d normal! ==", fold_start, fold_end))

    -- Wait for treesitter to update, then try to close fold
    vim.defer_fn(function()
      vim.fn.cursor(fold_start, 1)
      pcall(function()
        vim.cmd("normal! zc")
      end)
    end, 50)
  end
end

-- Smart Toggle: Handles Visual, Fold, and Normal lines
-- 智能注释切换：处理可视模式、折叠块和普通行
M.comment.smart_toggle = function()
  local mode = vim.fn.mode()

  -- === 1. VISUAL MODE Logic ===
  if mode:match("[vV]") or mode == "\22" then -- \22 is visual block mode
    -- Get visual selection range
    vim.cmd("normal! \27") -- Exit visual mode to capture marks
    local start_line = vim.fn.line("'<")
    local end_line = vim.fn.line("'>")
    local filetype = vim.bo.filetype

    -- Get fold text utilities
    local fold_utils = require("plugins.folding.utils")
    local line_comment = vim.bo.commentstring:gsub("%%s.*", ""):gsub("%s+$", "")
    local line_pattern = fold_utils.comment_type.filetype_comment_patterns[filetype]
    local lsp_pattern = fold_utils.comment_type.lsp_annotation_patterns[filetype]

    -- Fallback pattern if needed
    if not line_pattern then
      local comment_chars = line_comment:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
      line_pattern = "^%s*" .. comment_chars
    end

    -- Collect all fold ranges and non-fold lines
    local fold_ranges = {}
    local non_fold_lines = {}
    local processed_lines = {}

    for lnum = start_line, end_line do
      if not processed_lines[lnum] then
        local fold_start = vim.fn.foldclosed(lnum)
        if fold_start ~= -1 then
          local fold_end = vim.fn.foldclosedend(lnum)
          table.insert(fold_ranges, { start = fold_start, ending = fold_end })
          -- Mark all lines in this fold as processed
          for i = fold_start, fold_end do
            processed_lines[i] = true
          end
        else
          table.insert(non_fold_lines, lnum)
          processed_lines[lnum] = true
        end
      end
    end

    -- Determine if we should comment or uncomment based on ALL lines in selection
    local has_uncommented = false

    -- Check folds
    for _, fold_range in ipairs(fold_ranges) do
      vim.fn.cursor(fold_range.start, 1)
      vim.cmd("normal! zo") -- Open to check

      for i = fold_range.start, fold_range.ending do
        local line = vim.fn.getline(i)
        if not (lsp_pattern and line:match(lsp_pattern)) then
          if not line:match(line_pattern) then
            has_uncommented = true
            break
          end
        end
      end

      vim.fn.cursor(fold_range.start, 1)
      vim.cmd("normal! zc") -- Close it back

      if has_uncommented then
        break
      end
    end

    -- Check non-fold lines
    if not has_uncommented then
      for _, lnum in ipairs(non_fold_lines) do
        local line = vim.fn.getline(lnum)
        local trimmed = vim.trim(line)
        if trimmed ~= "" then
          if not (lsp_pattern and line:match(lsp_pattern)) then
            if not line:match(line_pattern) then
              has_uncommented = true
              break
            end
          end
        end
      end
    end

    -- Now apply the same action to ALL folds and lines
    if has_uncommented then
      -- COMMENT everything
      -- Handle folds
      for _, fold_range in ipairs(fold_ranges) do
        vim.fn.cursor(fold_range.start, 1)
        vim.cmd("normal! zo")

        for i = fold_range.start, fold_range.ending do
          local line = vim.fn.getline(i)
          if not (lsp_pattern and line:match(lsp_pattern)) then
            local indent = line:match("^%s*") or ""
            local content = line:sub(#indent + 1)
            local new_line = indent .. line_comment .. " " .. content
            vim.fn.setline(i, new_line)
          end
        end

        vim.fn.cursor(fold_range.start, 1)
        vim.cmd("normal! zc")
      end

      -- Handle non-fold lines
      for _, lnum in ipairs(non_fold_lines) do
        local line = vim.fn.getline(lnum)
        local trimmed = vim.trim(line)
        if trimmed ~= "" then
          if not (lsp_pattern and line:match(lsp_pattern)) then
            local indent = line:match("^%s*") or ""
            local content = line:sub(#indent + 1)
            local new_line = indent .. line_comment .. " " .. content
            vim.fn.setline(lnum, new_line)
          end
        end
      end
    else
      -- UNCOMMENT everything
      -- Handle folds
      for _, fold_range in ipairs(fold_ranges) do
        vim.fn.cursor(fold_range.start, 1)
        vim.cmd("normal! zo")

        for i = fold_range.start, fold_range.ending do
          local line = vim.fn.getline(i)
          if not (lsp_pattern and line:match(lsp_pattern)) then
            if line:match(line_pattern) then
              local new_line = line:gsub(line_pattern .. "%s?", "", 1)
              vim.fn.setline(i, new_line)
            end
          end
        end

        vim.cmd(string.format("silent! %d,%d normal! ==", fold_range.start, fold_range.ending))
        vim.defer_fn(function()
          vim.fn.cursor(fold_range.start, 1)
          pcall(function()
            vim.cmd("normal! zc")
          end)
        end, 50)
      end

      -- Handle non-fold lines
      for _, lnum in ipairs(non_fold_lines) do
        local line = vim.fn.getline(lnum)
        if not (lsp_pattern and line:match(lsp_pattern)) then
          if line:match(line_pattern) then
            local new_line = line:gsub(line_pattern .. "%s?", "", 1)
            vim.fn.setline(lnum, new_line)
          end
        end
      end
    end

    return
  end

  -- === 2. NORMAL MODE Logic ===
  local current_line = vim.fn.line(".")
  local fold_start = vim.fn.foldclosed(current_line)

  if fold_start ~= -1 then
    -- CASE A: On a Closed Fold (在闭合折叠上)
    M.comment.toggle_fold_or_line()
  else
    -- CASE B: Normal Line (普通行)
    M.comment.comment_line()
  end
end

-- =============================================================================
-- Line Management / 行管理
-- =============================================================================

M.line_manage = {}

-- Join lines keeping cursor position
-- 合并行
M.line_manage.join_lines = function()
  local v_count = vim.v.count1 + 1
  local mode = vim.api.nvim_get_mode().mode
  local keys = (mode == "n") and (v_count .. "J") or "J"
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "n", false)
end

-- Insert empty lines above/below
-- 在上方/下方插入空行
M.line_manage.insert_lines = function(direction)
  local line = vim.api.nvim_get_current_line()
  local indent = line:match("^%s*") or ""
  local lines = { "", "", "" } -- Buffer padding
  local row = vim.api.nvim_win_get_cursor(0)[1]

  if direction == "up" then
    vim.api.nvim_buf_set_lines(0, row - 1, row - 1, false, lines)
    vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
  else
    vim.api.nvim_buf_set_lines(0, row, row, false, lines)
    vim.api.nvim_win_set_cursor(0, { row + 2, 0 })
  end
  vim.cmd("startinsert")
  if #indent > 0 then
    vim.api.nvim_put({ indent }, "c", false, true)
  end
end

-- =============================================================================
-- Action (Undo/Redo) / 撤销与重做
-- =============================================================================

M.action = {}

M.action.undo = function()
  local mode = vim.api.nvim_get_mode().mode
  if mode == "n" or mode == "i" or mode == "v" then
    vim.cmd("undo")
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
  end
end

M.action.redo = function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
  vim.cmd("redo")
end

-- =============================================================================
-- Case Conversion / 变量名大小写转换
-- =============================================================================

-- Define keywords to ignore per filetype
-- 针对不同文件类型定义需要忽略的关键字 (不参与大小写转换)
local IGNORE_KEYWORDS = {
  lua = {
    "local",
    "function",
    "return",
    "end",
    "if",
    "then",
    "else",
    "elseif",
    "for",
    "while",
    "do",
    "repeat",
    "until",
    "break",
    "in",
    "true",
    "false",
    "nil",
  },
  python = {
    "def",
    "class",
    "return",
    "import",
    "from",
    "if",
    "elif",
    "else",
    "for",
    "while",
    "try",
    "except",
    "finally",
    "with",
    "as",
    "pass",
    "lambda",
    "None",
    "True",
    "False",
  },
  typescript = {
    "const",
    "let",
    "var",
    "function",
    "class",
    "interface",
    "type",
    "enum",
    "import",
    "export",
    "return",
    "if",
    "else",
    "switch",
    "case",
    "default",
    "try",
    "catch",
    "finally",
    "async",
    "await",
    "new",
    "this",
    "super",
  },
  javascript = { -- Inherits most from TS usually, but explicit list helps
    "const",
    "let",
    "var",
    "function",
    "class",
    "import",
    "export",
    "return",
    "if",
    "else",
    "async",
    "await",
  },
  rust = {
    "fn",
    "let",
    "mut",
    "pub",
    "struct",
    "enum",
    "impl",
    "use",
    "mod",
    "crate",
    "match",
    "if",
    "else",
    "loop",
    "while",
    "for",
    "return",
    "break",
    "continue",
    "const",
    "static",
    "type",
    "trait",
    "where",
    "unsafe",
    "async",
    "await",
  },
  swift = {
    "func",
    "var",
    "let",
    "class",
    "struct",
    "enum",
    "extension",
    "protocol",
    "init",
    "deinit",
    "return",
    "if",
    "else",
    "guard",
    "switch",
    "case",
    "default",
    "for",
    "in",
    "while",
    "repeat",
    "break",
    "continue",
    "try",
    "catch",
    "throw",
  },
  html = {
    -- HTML tags are usually lowercase, but we might want to ignore attribute names if needed
    -- HTML 标签通常小写，这里主要为了防止意外转换属性名
    "div",
    "span",
    "class",
    "id",
    "style",
    "script",
    "body",
    "head",
    "html",
  },
  css = {
    -- CSS properties
    "color",
    "background",
    "margin",
    "padding",
    "font",
    "border",
    "display",
  },
}

-- Add aliases (e.g., ts -> typescript)
-- 添加别名支持
IGNORE_KEYWORDS.ts = IGNORE_KEYWORDS.typescript
IGNORE_KEYWORDS.js = IGNORE_KEYWORDS.javascript
IGNORE_KEYWORDS.rs = IGNORE_KEYWORDS.rust

-- Utility Functions / 工具函数
local function capitalize(word)
  return word:sub(1, 1):upper() .. word:sub(2):lower()
end

local function lowercase(word)
  return word:lower()
end

-- 检查单词是否在当前文件类型的忽略列表中
local function is_keyword(word, ft)
  local list = IGNORE_KEYWORDS[ft]
  if not list then
    return false
  end
  for _, kw in ipairs(list) do
    if kw == word then
      return true
    end
  end
  return false
end

-- 现有的分词逻辑 (保留原样)
local function tokenize(text)
  local words = {}
  local current_word = ""

  for i = 1, #text do
    local char = text:sub(i, i)

    -- 1. Delimiters (Snake/Kebab)
    if char == "_" or char == "-" then
      if #current_word > 0 then
        table.insert(words, lowercase(current_word))
        current_word = ""
      end

    -- 2. Uppercase (Camel) -> Always split
    elseif char:match("%u") then
      if #current_word > 0 then
        table.insert(words, lowercase(current_word))
      end
      current_word = char

    -- 3. Digits -> Split if previous was NOT a digit
    elseif char:match("%d") then
      -- If current word exists and is NOT digits (i.e. letters), split
      -- 如果当前词存在且不是数字（即字母），分割。例如: "bob34" -> "bob", "34"
      if #current_word > 0 and not current_word:match("^%d+$") then
        table.insert(words, lowercase(current_word))
        current_word = ""
      end
      current_word = current_word .. char

    -- 4. Lowercase/Other -> Split if previous WAS a digit
    else
      -- If current word exists and IS digits, split
      -- 如果当前词存在且是数字，分割。例如: "mp3player" -> "mp", "3", "player"
      if #current_word > 0 and current_word:match("^%d+$") then
        table.insert(words, lowercase(current_word))
        current_word = ""
      end
      current_word = current_word .. char
    end
  end

  if #current_word > 0 then
    table.insert(words, lowercase(current_word))
  end

  return words
end -- Existing Case Detection (kept as is)

-- 现有的命名风格检测 (保留原样)
local function detect_case(text)
  local first_delim = nil
  local has_upper_after_start = false
  for i = 1, #text do
    local char = text:sub(i, i)
    if char == "_" then
      if not first_delim then
        first_delim = "_"
      end
    elseif char == "-" then
      if not first_delim then
        first_delim = "-"
      end
    elseif char:match("%u") and i > 1 then
      has_upper_after_start = true
      if not first_delim then
        return "camel"
      end
    end
  end
  if first_delim == "_" then
    return "snake"
  elseif first_delim == "-" then
    return "kebab"
  elseif has_upper_after_start then
    return "camel"
  else
    return "snake"
  end
end

local function convert_to_case(words, case_type)
  if case_type == "snake" then
    return table.concat(words, "_")
  elseif case_type == "kebab" then
    return table.concat(words, "-")
  elseif case_type == "camel" then
    local result = words[1]
    for i = 2, #words do
      result = result .. capitalize(words[i])
    end
    return result
  end
  return table.concat(words, "") -- Fallback
end

local function next_case(current_case)
  if current_case == "snake" then
    return "camel"
  elseif current_case == "camel" then
    return "kebab"
  else
    return "snake"
  end
end

-- Wrapper to process a single word/identifier
-- 处理单个单词/标识符的包装函数
local function process_identifier(text)
  local words = tokenize(text)
  if #words == 0 then
    return text
  end -- Return original if cannot tokenize
  local current_case = detect_case(text)
  local new_case = next_case(current_case)
  return convert_to_case(words, new_case)
end

-- Main Logic / 主逻辑
M.cycle_case = function()
  -- Get current mode
  local mode = vim.fn.mode()

  -- Validation: Must be in a visual mode
  if not (mode:match("[vV]") or mode == "\22") then
    -- Try to fallback to marks if not currently in visual mode (rare case)
    -- 如果当前不在 visual 模式，尝试回退到标记检测
    if vim.fn.getpos("'<")[2] == 0 then
      vim.notify("请先选中文件并在 Visual 模式下使用", vim.log.levels.WARN)
      return
    end
  end

  local start_pos, end_pos
  local start_line, start_col
  local end_line, end_col

  -- Detect positions dynamically based on active selection
  -- 动态检测坐标：使用 'v'(起点) 和 '.'(光标) 而非延迟更新的 marks
  if mode:match("[vV]") or mode == "\22" then
    local p1 = vim.fn.getpos("v")
    local p2 = vim.fn.getpos(".")

    -- Reorder to ensure start is always before end
    -- 重新排序确保 start 总是在 end 之前 (处理反向选择)
    if p1[2] < p2[2] or (p1[2] == p2[2] and p1[3] <= p2[3]) then
      start_pos, end_pos = p1, p2
    else
      start_pos, end_pos = p2, p1
    end
  else
    -- Fallback for marks (only if not active visual mode)
    start_pos = vim.fn.getpos("'<")
    end_pos = vim.fn.getpos("'>")
  end

  start_line, start_col = start_pos[2], start_pos[3]
  end_line, end_col = end_pos[2], end_pos[3]

  -- Safety check: Ensure valid lines
  -- 安全检查：确保行号有效
  if start_line == 0 or end_line == 0 then
    return
  end

  -- Check multi-line selection (Only support single line for now)
  -- 检查是否跨行 (目前仅支持单行)
  if start_line ~= end_line then
    vim.notify("目前仅支持单行选中", vim.log.levels.WARN)
    -- Optional: Exit visual mode to prevent stuck state
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
    return
  end

  -- Get line content safely
  -- 安全获取行内容
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, start_line, false)
  if #lines == 0 then
    return
  end -- Prevent nil error
  local line_content = lines[1]

  -- Handle Visual Line Mode ('V')
  -- 处理行选择模式 'V': 强制选中整行
  if mode == "V" then
    start_col = 1
    end_col = #line_content
  else
    -- Boundary check for charwise selection
    end_col = math.min(end_col, #line_content)
  end

  -- Extract text
  local text_selection = line_content:sub(start_col, end_col)

  -- Get filetype for ignore list
  local ft = vim.bo.filetype

  -- Process replacement
  -- 执行替换逻辑
  local new_selection = text_selection:gsub("([%w_%-]+)", function(word)
    if is_keyword(word, ft) then
      return word
    end
    if word:match("^%d+$") then
      return word
    end
    return process_identifier(word)
  end)

  -- Apply changes
  -- 应用更改
  vim.api.nvim_buf_set_text(
    0,
    start_line - 1,
    start_col - 1,
    start_line - 1,
    start_col - 1 + #text_selection,
    { new_selection }
  )

  -- Restore Visual Mode Selection
  -- 恢复选区：由于文本长度可能变化，我们需要计算新的结束位置
  -- Note: We switch to Normal mode then back to Visual to reset the range cleanly
  local new_end_col = start_col + #new_selection - 1

  -- Use feedkeys to re-select the new range naturally
  -- 使用 feedkeys 自然地重新选中新范围
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
  vim.schedule(function()
    -- Set cursor to start
    vim.api.nvim_win_set_cursor(0, { start_line, start_col - 1 })
    -- Re-enter visual mode and select to end
    local v_cmd = (mode == "V") and "V" or "v"
    vim.cmd("normal! " .. v_cmd)
    vim.api.nvim_win_set_cursor(0, { start_line, new_end_col - 1 })
  end)
end

return M
