-- 添加 multicursor.nvim 插件
vim.pack.add({
  { src = "https://github.com/jake-stewart/multicursor.nvim" },
})

-- 加载插件模块
local mc = require("multicursor-nvim")

-- 在首次进入 Insert 模式时初始化（避免重复调用）
vim.api.nvim_create_autocmd("InsertEnter", {
  once = true, -- 只执行一次
  callback = function()
    mc.setup({}) -- 初始化多光标功能
  end,
})

local set = vim.keymap.set

-- 在当前光标位置添加一个新光标
set({ "n", "x" }, "mm", function()
  mc.addCursor()
end, { desc = "在当前光标处添加 multicursor" })

-- 在上一行 / 下一行添加或移除光标
set({ "n", "x" }, "<up>", function()
  mc.lineAddCursor(-1)
end, { desc = "在上一行添加光标" })
set({ "n", "x" }, "<down>", function()
  mc.lineAddCursor(1)
end, { desc = "在下一行添加光标" })

-- 跳过上一行 / 下一行（不添加光标）
set({ "n", "x" }, "<leader><up>", function()
  mc.lineSkipCursor(-1)
end, { desc = "跳过上一行，不添加光标" })
set({ "n", "x" }, "<leader><down>", function()
  mc.lineSkipCursor(1)
end, { desc = "跳过下一行，不添加光标" })

-- 根据单词或选择内容添加匹配的光标（向下）
set({ "n", "x" }, "<C-d>", function()
  mc.matchAddCursor(1)
end, { desc = "根据选中内容向下匹配并添加光标" })

-- 根据单词或选择内容添加匹配的光标（向上）
set({ "n", "x" }, "mmn", function()
  mc.matchAddCursor(-1)
end, { desc = "根据选中内容向上匹配并添加光标" })

-- 用鼠标 Ctrl + 左键 添加/拖动/释放 多光标
set("n", "<c-leftmouse>", mc.handleMouse)
set("n", "<c-leftdrag>", mc.handleMouseDrag)
set("n", "<c-leftrelease>", mc.handleMouseRelease)

-- 启用或禁用 multicursor 功能
set({ "n", "x" }, "<leader>up", mc.toggleCursor, { desc = "启用/禁用 multicursor" })

-- 多光标专用模式：只有在存在多个光标时，这些按键才生效
mc.addKeymapLayer(function(layerSet)
  -- 切换主光标（上一个/下一个）
  layerSet({ "n", "x" }, "[p", mc.prevCursor)
  layerSet({ "n", "x" }, "]p", mc.nextCursor)

  -- 按 ESC：如果禁用光标 → 启用；否则 → 清除所有光标
  layerSet("n", "<esc>", function()
    if not mc.cursorsEnabled() then
      mc.enableCursors()
    else
      mc.clearCursors()
    end
  end)
end)

-- 设置多光标的高亮样式
local hl = vim.api.nvim_set_hl
hl(0, "MultiCursorCursor", { reverse = true }) -- 主光标样式
hl(0, "MultiCursorVisual", { link = "Visual" }) -- 多光标的视觉模式样式
hl(0, "MultiCursorSign", { link = "SignColumn" }) -- 多光标左侧符号栏
hl(0, "MultiCursorMatchPreview", { link = "IncSearch" }) -- 匹配预览样式
hl(0, "MultiCursorDisabledCursor", { reverse = true }) -- 禁用状态的光标
hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
