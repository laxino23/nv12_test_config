return {
  {
    -- 核心插件: Neotest (统一的测试运行框架)
    "nvim-neotest/neotest",

    -- 依赖项: 这里列出了 Neotest 需要的语言适配器
    dependencies = {
      "fredrikaverpil/neotest-golang", -- Go 语言的测试适配器
      "lawrence-laz/neotest-zig", -- Zig 语言的测试适配器
    },

    -- 插件配置选项
    opts = {
      -- 适配器配置: 在这里定义各个语言的具体行为
      adapters = {

        -- =========================================================
        -- 1. Go 语言配置 (neotest-golang)
        -- =========================================================
        ["neotest-golang"] = {
          -- Go 测试参数:
          -- "-v": 显示详细输出 (verbose)
          -- "-race": 开启竞态检测 (data race detection)
          -- "-count=1": 禁用测试缓存，强制每次都运行
          -- go_test_args = { "-v", "-race", "-count=1", "-timeout=60s" },

          -- 开启 DAP 调试支持:
          -- 设置为 true 后，你可以对测试设置断点并进行调试
          -- 注意: 这需要你已经安装了 `leoluz/nvim-dap-go` 插件
          dap_go_enabled = true,
        },

        -- =========================================================
        -- 2. Zig 语言配置 (neotest-zig)
        -- =========================================================
        ["neotest-zig"] = {}, -- 目前使用默认配置，暂无自定义选项

        -- =========================================================
        -- 3. Rust 语言配置 (rustaceanvim)
        -- =========================================================
        -- 注意: 这个适配器通常来自 `mrcjkb/rustaceanvim` 插件
        -- 它不是通过 dependencies 安装的，而是利用 rustaceanvim 自身集成的功能
        ["rustaceanvim.neotest"] = {},
      },
    },
  },
}
