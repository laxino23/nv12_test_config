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

-- Move lines in Normal mode (Fold aware)
-- 普通模式下移动行（感知折叠）
M.lineMovement.move_normal_selection = function(direction)
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
    local prev_start = vim.fn.foldclosed(prev_line)

    vim.cmd(start_line .. "," .. end_line .. "m " .. (prev_start - 1))

    local new_start = prev_start
    local new_end = new_start + (end_line - start_line)
    vim.cmd(new_start .. "," .. new_end .. "=")

    local adjust = start_line - prev_start
    vim.fn.cursor(cur - adjust, vim.fn.col("."))
  end
end

-- Move selection in Visual mode
-- 可视模式下移动选区
M.lineMovement.move_visual_selection = function(direction)
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

-- Toggle comment for line or fold
-- 切换行或折叠的注释状态
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
  local bufnr = vim.api.nvim_get_current_buf()
  local filetype = vim.bo.filetype

  -- Get fold text utilities
  local fold_utils = require("plugins.folding.utils")

  -- Open fold to inspect
  vim.cmd("normal! zo")

  -- Check if it's a comment block and what style
  local is_comment, is_block_style =
    fold_utils.helperFunction.is_comment_block(bufnr, fold_start, fold_end, filetype)

  local line_comment = vim.bo.commentstring:gsub("%%s.*", ""):gsub("%s+$", "")
  local line_pattern = fold_utils.commentType.filetype_comment_patterns[filetype]
  local block_pattern = fold_utils.commentType.filetype_block_comment_patterns[filetype]
  local lsp_pattern = fold_utils.commentType.lsp_annotation_patterns[filetype]

  if is_block_style and block_pattern then
    -- === CASE 2A: Block comment fold (--[[ ]]-- style) ===
    -- Remove block comment markers
    local first_line = vim.fn.getline(fold_start)
    local last_line = vim.fn.getline(fold_end)

    -- Remove start marker (preserve indentation)
    local indent = first_line:match("^%s*")
    local new_first = first_line:gsub(block_pattern.start, indent, 1)

    -- Remove end marker
    local new_last = last_line:gsub(block_pattern.ending, "", 1)

    vim.fn.setline(fold_start, new_first)
    vim.fn.setline(fold_end, new_last)

    -- Format the range to help treesitter recognize it
    vim.cmd(string.format("silent! %d,%d normal! ==", fold_start, fold_end))

    -- Wait for treesitter to update, then try to close fold
    vim.defer_fn(function()
      -- Move cursor to fold start and try to close
      vim.fn.cursor(fold_start, 1)
      pcall(function()
        vim.cmd("normal! zc")
      end)
    end, 50)
  elseif is_comment then
    -- === CASE 2B: Line comment fold (all lines are commented) ===
    -- Uncomment all lines (except LSP annotations)
    for i = fold_start, fold_end do
      local line = vim.fn.getline(i)
      local trimmed = vim.trim(line)

      -- Skip empty lines and LSP annotations
      if trimmed ~= "" and not (lsp_pattern and line:match(lsp_pattern)) then
        if line_pattern and line:match(line_pattern) then
          -- Remove comment sign
          local new_line = line:gsub(line_pattern .. "%s?", "", 1)
          vim.fn.setline(i, new_line)
        end
      end
    end

    -- Format the range to help treesitter recognize it as code
    vim.cmd(string.format("silent! %d,%d normal! ==", fold_start, fold_end))

    -- Wait for treesitter to update, then try to close fold
    vim.defer_fn(function()
      -- Move cursor to fold start and try to close
      vim.fn.cursor(fold_start, 1)
      pcall(function()
        vim.cmd("normal! zc")
      end)
    end, 50)
  else
    -- === CASE 2C: Not a comment fold - comment all lines ===
    -- Comment all non-empty lines (except LSP annotations)
    for i = fold_start, fold_end do
      local line = vim.fn.getline(i)
      local trimmed = vim.trim(line)

      if trimmed ~= "" and not (lsp_pattern and line:match(lsp_pattern)) then
        if line_pattern and not line:match(line_pattern) then
          -- Add comment sign (preserve indentation)
          local indent = line:match("^%s*") or ""
          local content = line:sub(#indent + 1)
          local new_line = indent .. line_comment .. " " .. content
          vim.fn.setline(i, new_line)
        end
      end
    end

    -- After commenting, manually create a fold with zf
    -- Move to fold start and create fold to fold end
    vim.fn.cursor(fold_start, 1)
    vim.cmd(string.format("normal! V%dGzf", fold_end))
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

    -- Check if any line in the selection is part of a fold
    local has_fold = false
    local fold_ranges = {} -- Store all fold ranges in selection

    for lnum = start_line, end_line do
      local fold_start = vim.fn.foldclosed(lnum)
      if fold_start ~= -1 then
        local fold_end = vim.fn.foldclosedend(lnum)
        -- Check if we haven't already recorded this fold
        local already_recorded = false
        for _, range in ipairs(fold_ranges) do
          if range.start == fold_start and range.ending == fold_end then
            already_recorded = true
            break
          end
        end
        if not already_recorded then
          table.insert(fold_ranges, { start = fold_start, ending = fold_end })
          has_fold = true
        end
      end
    end

    if has_fold then
      -- Handle multiple folds in selection
      for _, fold_range in ipairs(fold_ranges) do
        vim.fn.cursor(fold_range.start, 1)
        M.comment.toggle_fold_or_line()
      end
    else
      -- No folds, just toggle comments on the range
      -- Use native commenting on each line
      for lnum = start_line, end_line do
        local line = vim.fn.getline(lnum)
        if vim.trim(line) ~= "" then -- Skip empty lines
          vim.fn.cursor(lnum, 1)
          M.comment.comment_line()
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

return M
