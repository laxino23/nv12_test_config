local M = {}
local icons = require("config.ui").icons.fold

-- 1. Configuration & Patterns
local filetype_comment_patterns = {
  lua = "^%s*%-%-",
  python = "^%s*#",
  javascript = "^%s*//",
  typescript = "^%s*//",
  c = "^%s*//",
  cpp = "^%s*//",
  rust = "^%s*//",
  go = "^%s*//",
  java = "^%s*//",
  vim = '^%s*"',
  sql = "^%s*%-%-",
  sh = "^%s*#",
  bash = "^%s*#",
}

local filetype_block_comment_patterns = {
  lua = { start = "^%s*%-%-%s*%[%[", ending = "%]%]%s*$" },
  python = { start = '^%s*"""', ending = '"""%s*$' },
  c = { start = "^%s*/%*", ending = "%*/%s*$" },
  cpp = { start = "^%s*/%*", ending = "%*/%s*$" },
  java = { start = "^%s*/%*", ending = "%*/%s*$" },
  javascript = { start = "^%s*/%*", ending = "%*/%s*$" },
  typescript = { start = "^%s*/%*", ending = "%*/%s*$" },
  rust = { start = "^%s*/%*", ending = "%*/%s*$" },
  css = { start = "^%s*/%*", ending = "%*/%s*$" },
  html = { start = "^%s*<!%-%-", ending = "%--%>%s*$" },
}

local lsp_annotation_patterns = {
  lua = "^%s*%-%-%-@",
  python = "^%s*#%s*:type",
  typescript = "^%s*//%s*@",
  javascript = "^%s*//%s*@",
}

-- 2. Helper Functions (Detection)
local function is_comment_line(line_text, filetype)
  local pattern = filetype_comment_patterns[filetype]
  return pattern and line_text:match(pattern) ~= nil
end

local function is_lsp_annotation(line_text, filetype)
  local pattern = lsp_annotation_patterns[filetype]
  return pattern and line_text:match(pattern) ~= nil
end

local function starts_with_block_comment(bufnr, lnum, filetype)
  local patterns = filetype_block_comment_patterns[filetype]
  local line = vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1]
  return patterns and line and line:match(patterns.start) ~= nil
end

local function ends_with_block_comment(bufnr, endLnum, filetype)
  local patterns = filetype_block_comment_patterns[filetype]
  local line = vim.api.nvim_buf_get_lines(bufnr, endLnum - 1, endLnum, false)[1]
  return patterns and line and line:match(patterns.ending) ~= nil
end

local function is_comment_block(bufnr, lnum, endLnum, filetype)
  if
    starts_with_block_comment(bufnr, lnum, filetype)
    and ends_with_block_comment(bufnr, endLnum, filetype)
  then
    return true, true
  end
  local first_line = vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1]
  if first_line and is_lsp_annotation(first_line, filetype) then
    return true, false
  end
  local lines_to_check = { lnum, math.floor((lnum + endLnum) / 2), endLnum }
  for _, line_num in ipairs(lines_to_check) do
    local line = vim.api.nvim_buf_get_lines(bufnr, line_num - 1, line_num, false)[1]
    if not line or not is_comment_line(line, filetype) then
      return false, false
    end
  end
  return true, false
end

-- 3. Cleaning Logic

-- Strip prefix signs (for Block-Style Comments ONLY)
local function remove_start_comment_sign(text, filetype)
  local trimmed = vim.trim(text)
  if filetype == "lua" then
    return trimmed:gsub("^%-%-%-+%s*", ""):gsub("^%-%-+%s*", "")
  elseif filetype == "python" or filetype == "sh" or filetype == "bash" then
    return trimmed:gsub("^#+%s*", "")
  elseif
    filetype == "javascript"
    or filetype == "typescript"
    or filetype == "c"
    or filetype == "cpp"
    or filetype == "java"
    or filetype == "rust"
    or filetype == "go"
  then
    return trimmed:gsub("^//+%s*", ""):gsub("^/%*+%s*", "")
  end
  return trimmed
end

-- Process First Line Chunks
-- Handles stripping trailing comments for code, or stripping prefixes for TRUE block comments only.
local function process_first_line(virtText, filetype, is_comment, is_block_style)
  local cleaned_chunks = {}

  -- Only strip comment prefix if it's a BLOCK-STYLE comment (e.g., --[[ ]], /* */)
  -- For single-line comment blocks (e.g., multiple -- lines), keep the prefix intact
  if is_comment and is_block_style then
    -- Case A: Block-Style Comment (e.g., --[[ text ]] or /* text */)
    -- Remove the comment opener from the first chunk, keep the text
    local found_prefix = false
    for _, chunk in ipairs(virtText) do
      local text = chunk[1]
      local hl = chunk[2]

      -- Only clean the first comment chunk we find
      if not found_prefix and type(hl) == "string" and hl:lower():match("comment") then
        text = remove_start_comment_sign(text, filetype)
        found_prefix = true
      end

      if text ~= "" then
        table.insert(cleaned_chunks, { text, hl })
      end
    end
  elseif not is_comment then
    -- Case B: Code Block (e.g., local x = 1 -- comment)
    -- Stop adding chunks as soon as we hit a comment (trailing comment removal)
    for _, chunk in ipairs(virtText) do
      local hl = chunk[2]
      -- If we hit a comment chunk in a code block, it's a trailing comment -> Skip it and everything after
      if type(hl) == "string" and hl:lower():match("comment") then
        break
      end
      table.insert(cleaned_chunks, chunk)
    end
  else
    -- Case C: Single-line comment block (e.g., multiple -- lines)
    -- Keep everything as-is, including the comment prefix
    for _, chunk in ipairs(virtText) do
      table.insert(cleaned_chunks, chunk)
    end
  end

  return cleaned_chunks
end

-- Clean Last Line by Regex
local function clean_last_line_by_regex(text, filetype, is_block_style, is_comment)
  if is_comment then
    -- For any comment block (block-style OR single-line), remove the comment prefix
    if filetype == "lua" or filetype == "sql" then
      return text:gsub("^%s*%-%-+%s*", "")
    elseif filetype == "python" or filetype == "sh" or filetype == "bash" or filetype == "ruby" then
      return text:gsub("^%s*#+%s*", "")
    elseif
      filetype == "javascript"
      or filetype == "typescript"
      or filetype == "c"
      or filetype == "cpp"
      or filetype == "rust"
      or filetype == "go"
      or filetype == "java"
    then
      return text:gsub("^%s*//+%s*", ""):gsub("^%s*/%*+%s*", "")
    elseif filetype == "vim" then
      return text:gsub('^%s*"+%s*', "")
    elseif filetype == "html" or filetype == "xml" or filetype == "markdown" then
      return text:gsub("^%s*<!%-%-+%s*", "")
    end
  else
    -- For code blocks, remove trailing comments
    if filetype == "lua" or filetype == "sql" then
      return text:gsub("%s*%-%-.*$", "")
    elseif filetype == "python" or filetype == "sh" or filetype == "bash" or filetype == "ruby" then
      return text:gsub("%s*#.*$", "")
    elseif
      filetype == "javascript"
      or filetype == "typescript"
      or filetype == "c"
      or filetype == "cpp"
      or filetype == "rust"
      or filetype == "go"
      or filetype == "java"
    then
      return text:gsub("%s*//.*$", "")
    end
  end
  return text
end

local function get_last_line_virt_text(ctx, endLnum, filetype, is_block_style, is_comment)
  local last_line = vim.api.nvim_buf_get_lines(ctx.bufnr, endLnum - 1, endLnum, false)[1]
  if not last_line or last_line == "" then
    return {}
  end

  local cleaned_text = clean_last_line_by_regex(last_line, filetype, is_block_style, is_comment)
  cleaned_text = vim.trim(cleaned_text)

  if cleaned_text ~= "" then
    local hl = is_comment and "Comment" or "Normal"
    return { { cleaned_text, hl } }
  end
  return {}
end

-- 4. Main Handler
M.handler = function(virtText, lnum, endLnum, width, truncate, ctx)
  local newVirtText = {}
  local filetype = vim.bo[ctx.bufnr].filetype
  local fold_lines = endLnum - lnum
  local suffix = string.format(" %s %d lines", icons.lines or " 󰁂 ", fold_lines)
  local sufWidth = vim.fn.strdisplaywidth(suffix)

  -- Determine if it's a comment block
  local is_comment, is_block_style = is_comment_block(ctx.bufnr, lnum, endLnum, filetype)

  -- 1. Handle First Line (with trailing removal or prefix stripping)
  local first_line_chunks = process_first_line(virtText, filetype, is_comment, is_block_style)

  -- Render First Line
  local targetWidth = width - sufWidth
  local curWidth = 0
  for _, chunk in ipairs(first_line_chunks) do
    local chunkText = chunk[1]
    local chunkWidth = vim.fn.strdisplaywidth(chunkText)
    if targetWidth > curWidth + chunkWidth then
      table.insert(newVirtText, chunk)
      curWidth = curWidth + chunkWidth
    else
      chunkText = truncate(chunkText, targetWidth - curWidth)
      table.insert(newVirtText, { chunkText, chunk[2] })
      curWidth = curWidth + chunkWidth
      break
    end
  end

  -- 2. Add Separator
  local separator = string.format(" %s ", icons.omit or " ... ")
  local sepWidth = vim.fn.strdisplaywidth(separator)
  table.insert(newVirtText, { separator, "Comment" })

  -- 3. Handle Last Line
  if fold_lines > 0 then
    local last_line_chunks =
      get_last_line_virt_text(ctx, endLnum, filetype, is_block_style, is_comment)
    if last_line_chunks and #last_line_chunks > 0 then
      local used_width = curWidth + sepWidth + sufWidth
      local remaining_space = width - used_width
      if remaining_space > 2 then
        for _, chunk in ipairs(last_line_chunks) do
          local text = chunk[1]
          local hl = chunk[2]
          local text_width = vim.fn.strdisplaywidth(text)
          if text_width <= remaining_space then
            table.insert(newVirtText, { text, hl })
            remaining_space = remaining_space - text_width
          else
            text = truncate(text, remaining_space)
            if text ~= "" then
              table.insert(newVirtText, { text, hl })
            end
            break
          end
        end
      end
    end
  end

  -- 4. Add Suffix
  table.insert(newVirtText, { suffix, "MoreMsg" })

  return newVirtText
end

M.helper_function = {
  is_comment_block = is_comment_block,
  is_comment_line = is_comment_line,
}
M.comment_type = {
  lsp_annotation_patterns = lsp_annotation_patterns,
  filetype_comment_patterns = filetype_comment_patterns,
  filetype_block_comment_patterns = filetype_block_comment_patterns,
}
return M
