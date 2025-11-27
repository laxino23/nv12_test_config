return {
  -- =========================================================
  -- 1. Crates.nvim: Cargo.toml 依赖管理增强
  --    提供版本自动补全、查看版本信息等
  -- =========================================================
  {
    "Saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    opts = {
      completion = {
        crates = {
          enabled = true, -- 开启 crate 名称和版本补全
        },
      },
      lsp = {
        enabled = true,
        actions = true, -- 开启 "Update to latest" 等代码操作
        completion = true,
        hover = true, -- 悬停显示 crate 详细信息
      },
    },
  },

  -- =========================================================
  -- 2. Rustaceanvim: Rust 开发核心插件
  --    替代了 rust-tools.nvim，提供 LSP、DAP、Inlay Hints 等
  -- =========================================================
  {
    "mrcjkb/rustaceanvim",
    version = "^5", -- 建议锁定版本，避免 API 变动导致报错 (目前主流是 v5)
    ft = { "rust" },
    opts = {
      tools = {
        float_win_config = {
          border = "rounded",
        },
      },
      server = {
        on_attach = function(_, bufnr)
          -- 这里可以绑定专门针对 Rust 的快捷键，例如 hover actions
        end,
        default_settings = {
          -- rust-analyzer 语言服务器配置
          ["rust-analyzer"] = {
            cargo = {
              allFeatures = true, -- 默认开启所有 feature，避免代码报“未启用 feature”的错
              loadOutDirsFromCheck = true,
              buildScripts = {
                enable = true,
              },
            },
            checkOnSave = true, -- 保存时自动检查 (cargo check)
            diagnostics = {
              enable = true,
            },
            procMacro = {
              enable = true,
              -- 忽略某些导致分析器卡顿的宏
              ignored = {
                ["async-trait"] = { "async_trait" },
                ["napi-derive"] = { "napi" },
                ["async-recursion"] = { "async_recursion" },
              },
            },
            files = {
              excludeDirs = {
                ".direnv",
                ".git",
                ".github",
                ".gitlab",
                "bin",
                "node_modules",
                "target",
                "venv",
                ".venv",
              },
            },
          },
        },
      },
    },

    -- =========================================================
    -- 关键修复: 动态配置 DAP (调试器) 路径
    -- =========================================================
    config = function(_, opts)
      -- 尝试使用 mason-registry 自动寻找安装路径，而不是硬编码
      -- 确保你已经在 Mason 里安装了 "codelldb"
      local mason_registry = require("mason-registry")
      local codelldb_root = ""
      local codelldb_path = ""
      local liblldb_path = ""

      if mason_registry.is_installed("codelldb") then
        local codelldb = mason_registry.get_package("codelldb")
        codelldb_root = codelldb:get_install_path()
        local extension_path = codelldb_root .. "/extension/"

        -- 定义可执行文件路径
        codelldb_path = extension_path .. "adapter/codelldb"

        -- 定义库文件路径 (根据系统判断)
        local this_os = vim.uv.os_uname().sysname
        if this_os:find("Windows") then
          liblldb_path = extension_path .. "lldb\\bin\\liblldb.dll"
        elseif this_os:find("Linux") then
          liblldb_path = extension_path .. "lldb/lib/liblldb.so"
        else
          -- macOS 路径
          liblldb_path = extension_path .. "lldb/lib/liblldb.dylib"
        end
      else
        -- 如果没用 Mason，尝试从 PATH 读取 (备用方案)
        codelldb_path = vim.fn.exepath("codelldb")
        -- 注意: 如果不是 Mason 安装的，liblldb 的路径很难猜，这里仅做简单回退
      end

      -- 将路径注入到 rustaceanvim 的 DAP 配置中
      opts.dap = {
        adapter = require("rustaceanvim.config").get_codelldb_adapter(codelldb_path, liblldb_path),
      }

      -- 设置全局变量 (rustaceanvim 不使用 setup()，而是读取 vim.g.rustaceanvim)
      vim.g.rustaceanvim = vim.tbl_deep_extend("keep", vim.g.rustaceanvim or {}, opts or {})

      -- 检查依赖
      if vim.fn.executable("rust-analyzer") == 0 then
        Snacks.notify.error(
          "**rust-analyzer** not found in PATH, please install it.\nRun `:MasonInstall rust-analyzer`",
          { title = "rustaceanvim" }
        )
      end
    end,
  },
}
