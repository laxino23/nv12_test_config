return {
  "A7Lavinraj/fyler.nvim",

  -- [依赖] 需要 mini.icons (或者 nvim-web-devicons) 来显示文件图标
  dependencies = { "nvim-mini/mini.icons" },

  -- [懒加载] 只有执行 :Fyler 命令或按快捷键时才加载插件
  cmd = "Fyler",

  keys = {
    {
      "<leader>o",
      "<cmd>Fyler kind=float<cr>", -- 以浮动窗口模式打开 Fyler
      desc = "Fyler (打开文件管理器)",
    },
  },

  opts = {
    views = {
      finder = {
        -- 简单确认模式：通常指选中文件后的行为更直接
        confirm_simple = true,
      },
      watcher = {
        -- 文件监控：如果在终端或其他地方新建了文件，Fyler 会自动刷新显示
        enabled = true,
      },
      win = {
        -- 窗口外观设置
        border = "single", -- 边框样式 (single, double, rounded, solid, shadow)
        kind = "float", -- 默认窗口类型：浮动窗口 (float) 还是侧边栏 (sidebar)

        -- 针对 "float" 类型的具体尺寸配置
        kinds = {
          float = {
            height = "80%", -- 高度占屏幕 80%
            width = "80%", -- 宽度占屏幕 80%
            top = "10%", -- 距离顶部 10% (实现垂直居中)
            left = "10%", -- 距离左侧 10% (实现水平居中)
          },
        },
      },
    },
  },
}
