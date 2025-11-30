-- 1. 注册插件 (只下载，不自动加载 plugin/ 下的脚本)
vim.pack.add({
  {
    src = "https://github.com/folke/snacks.nvim",
    name = "snacks.nvim",
    version = "main",
  },
}, {
  load = false,
})

-- 2. 状态管理变量
local snacks_loaded = false
local load_lock = false

-- 3. 真正的加载函数 (当按下快捷键或调用 API 时触发)
local function load_snacks()
  -- 防止递归调用或重复加载
  if snacks_loaded or load_lock then
    return
  end
  load_lock = true

  -- 再次检查 package.loaded (防止多线程竞态)
  if package.loaded["snacks"] then
    snacks_loaded = true
    load_lock = false
    return
  end

  -- A. 手动加载插件核心
  vim.cmd.packadd("snacks.nvim")

  -- B. 加载 Picker and Indent 配置
  local ok_1, picker_config = pcall(require, "plugins.snacks.picker")
  if not ok_1 then
    vim.notify("Snacks Picker 配置加载失败: " .. tostring(picker_config), vim.log.levels.WARN)
    picker_config = {}
  end

  local ok_2, indent_config = pcall(require, "plugins.indent")
  if not ok_2 then
    vim.notify("Snacks Indent 配置加载失败: " .. tostring(indent_config), vim.log.levels.WARN)
    indent_config = {}
  end

  -- C. 组装最终配置 opts
  local opts = {
    -- 集成 Picker and Indent 配置
    picker = picker_config,
    indent = indent_config.indent,
    chunk = indent_config.chunk,
    scope = indent_config.scope,
    -- 开启其他常用模块
    eplorer = { enabled = true, replace_netrw = false },
    image = { enabled = true },
    dim = { enabled = false },
    zen = { enabled = true },
    scroll = { enabled = false },
    input = { enabled = true },
    words = { enabled = true },
    statuscolumn = {
      left = { "mark", "sign" },
      right = { "fold", "git" },
      folds = { open = true, git_hl = true },
    },
    notifier = { enabled = true },
    toggle = { enabled = true },
    lazygit = { enabled = false },
    terminal = { enabled = true },
    gitbrowse = { enabled = true },
    dashboard = { enabled = true },
  }

  -- D. 调用 setup 初始化
  local setup_ok, err = pcall(function()
    require("snacks").setup(opts)
  end)

  if setup_ok then
    snacks_loaded = true
  else
    vim.notify("Snacks Setup 失败: " .. tostring(err), vim.log.levels.ERROR)
  end

  load_lock = false
end

-- 4. 创建全局代理 _G.Snacks (实现延迟加载的核心)
_G.Snacks = setmetatable({}, {
  __index = function(t, key)
    if not snacks_loaded then
      load_snacks()
    end
    local m = package.loaded["snacks"]
    return m and m[key]
  end,
  __call = function(t, ...)
    if not snacks_loaded then
      load_snacks()
    end
    local m = package.loaded["snacks"]
    if m and type(m) == "function" then
      return m(...)
    end
  end,
})

-- 5. 立即注册快捷键 (关键步骤！)
-- 必须在启动时读取 keymaps.lua，否则你按键没反应
-- 注意路径：lua/plugins/snacks/keymaps.lua -> plugins.snacks.keymaps
local keys_ok, keys_module = pcall(require, "plugins.snacks.keymaps")

if keys_ok and type(keys_module) == "table" then
  for name, map in pairs(keys_module) do
    -- 解析参数
    local mode = map.mode or map[1] or "n"
    local lhs = map.lhs or map[2]
    local rhs = map.rhs or map[3]
    local desc = map.desc

    -- 注册按键
    if lhs and rhs then
      vim.keymap.set(mode, lhs, rhs, {
        desc = desc or name,
        silent = true,
      })
    end
  end
else
  vim.notify("Snacks Keymaps 加载失败", vim.log.levels.WARN)
end

-- 6. Dashboard 逻辑 (如果没打开文件，延迟加载显示 Dashboard)
if vim.fn.argc() == 0 then
  vim.api.nvim_create_autocmd("UIEnter", {
    callback = function()
      vim.defer_fn(load_snacks, 10)
    end,
    once = true,
  })
end

-- 返回控制接口
return { load = load_snacks }
