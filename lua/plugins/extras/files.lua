local map = require("config.keymaps").map

-- ============================================================================
-- Helper: Open buffer in split / 辅助函数：分屏打开 Buffer
-- ============================================================================
local function open_buf_in_split(buf_id, key_map, direction)
  local MiniFiles = require("mini.files")
  local function rhs()
    local cur_target = MiniFiles.get_explorer_state().target_window
    if cur_target == nil or MiniFiles.get_fs_entry().fs_type == "directory" then
      return
    end
    local new_target = vim.api.nvim_win_call(cur_target, function()
      vim.cmd(direction .. " split")
      return vim.api.nvim_get_current_win()
    end)
    MiniFiles.set_target_window(new_target)
    MiniFiles.go_in({ close_on_file = true })
  end
  vim.keymap.set(
    "n",
    key_map,
    rhs,
    { buffer = buf_id, desc = "Split " .. string.sub(direction, 12) }
  )
end

-- ============================================================================
-- Mini.files Setup
-- ============================================================================
require("mini.files").setup({
  mappings = {
    show_help = "?",
    go_in_plus = "<cr>",
    go_out_plus = "-",
  },
  content = {
    filter = function(entry)
      return entry.name ~= ".DS_Store"
    end,
  },
  options = { permanent_delete = false },
})

map({
  ["File explorer"] = {
    "n",
    "<leader>e",
    function()
      local bufname = vim.api.nvim_buf_get_name(0)
      local path = vim.fn.fnamemodify(bufname, ":p")
      if path and vim.uv.fs_stat(path) then
        require("mini.files").open(bufname, false)
      else
        require("mini.files").open()
      end
    end,
  },
})

-- ============================================================================
-- MiniFiles Autocmds (Events & LSP Rename)
-- ============================================================================
local minifiles_augroup = vim.api.nvim_create_augroup("MiniFilesUser", { clear = true })

vim.api.nvim_create_autocmd("User", {
  group = minifiles_augroup,
  pattern = "MiniFilesWindowOpen",
  callback = function(args)
    local win_id = args.data.win_id
    vim.wo[win_id].winblend = 0
    local config = vim.api.nvim_win_get_config(win_id)
    config.border = "single"
    vim.api.nvim_win_set_config(win_id, config)
  end,
})

vim.api.nvim_create_autocmd("User", {
  group = minifiles_augroup,
  pattern = "MiniFilesBufferCreate",
  callback = function(args)
    local buf_id = args.data.buf_id
    -- Toggle dotfiles
    vim.keymap.set("n", "g.", function()
      vim.g.show_dotfiles = not vim.g.show_dotfiles
      require("mini.files").refresh({
        content = {
          filter = function(entry)
            return vim.g.show_dotfiles or entry.name:sub(1, 1) ~= "."
          end,
        },
      })
    end, { buffer = buf_id, desc = "Toggle `.`-files" })

    -- Split mappings
    open_buf_in_split(buf_id, "<C-h>", "topleft vertical")
    open_buf_in_split(buf_id, "<C-j>", "belowright horizontal")
    open_buf_in_split(buf_id, "<C-k>", "topleft horizontal")
    open_buf_in_split(buf_id, "<C-l>", "belowright vertical")
    open_buf_in_split(buf_id, "<C-t>", "tab")
  end,
})

-- LSP Rename Integration
vim.api.nvim_create_autocmd("User", {
  group = minifiles_augroup,
  pattern = "MiniFilesActionRename",
  callback = function(args)
    local changes = {
      files = {
        {
          oldUri = vim.uri_from_fname(args.data.from),
          newUri = vim.uri_from_fname(args.data.to),
        },
      },
    }
    local clients = vim.lsp.get_clients()
    for _, client in ipairs(clients) do
      if client:supports_method("workspace/willRenameFiles") then
        local res = client:request_sync("workspace/willRenameFiles", changes, 1000, 0)
        if res and res.result then
          vim.lsp.util.apply_workspace_edit(res.result, client.offset_encoding)
        end
      end
    end
    for _, client in ipairs(clients) do
      if client:supports_method("workspace/didRenameFiles") then
        client:notify("workspace/didRenameFiles", changes)
      end
    end
  end,
})
