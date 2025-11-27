return {
  -- ========================================================================
  -- 1. nvim-dap: 核心调试适配器协议 (DAP) 客户端
  -- ========================================================================
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      -- DAP 的 UI 界面依赖（在下面单独配置）
      { "nvim-dap-view" },

      -- 虚拟文本：在代码行旁边直接显示变量的值（类似 VS Code 的功能）
      { "theHamsta/nvim-dap-virtual-text", opts = {} },

      -- 专门用于调试 Neovim 自身的 Lua 代码的适配器
      {
        "jbyuki/one-small-step-for-vimkind",
        keys = {
          {
            "<leader>dL",
            function()
              require("osv").launch({ port = 8086 })
            end,
            desc = "启动 OSV Lua 调试服务器", -- 用于调试 Neovim 配置本身
          },
        },
        config = function()
          local dap = require("dap")

          -- 配置 nlua 适配器连接到本地 8086 端口
          dap.adapters.nlua = function(callback, config)
            callback({
              type = "server",
              host = config.host or "127.0.0.1",
              port = config.port or 8086,
            })
          end
          -- 定义 Lua 的调试配置：连接到正在运行的 Neovim 实例
          dap.configurations.lua = {
            {
              type = "nlua",
              request = "attach",
              name = "Attach to running Neovim instance (连接到运行中的 Neovim)",
            },
          }
        end,
      },
    },

    -- 配置 DAP 的外观图标和高亮
    config = function()
      -- 设置调试行的高亮，使其看起来像 Visual 模式的选择
      vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

      -- 定义侧边栏（SignColumn）的图标
      vim.fn.sign_define(
        "DapStopped", -- 程序暂停时的当前行图标
        {
          text = "󰁕 ",
          texthl = "DiagnosticWarn",
          linehl = "DapStoppedLine",
          numhl = "DapStoppedLine",
        }
      )
      vim.fn.sign_define(
        "DapBreakpoint",
        { text = " ", texthl = "DiagnosticInfo", priority = 1000 }
      ) -- 普通断点
      vim.fn.sign_define(
        "DapBreakpointCondition",
        { text = " ", texthl = "DiagnosticInfo", priority = 1000 }
      ) -- 条件断点
      vim.fn.sign_define(
        "DapBreakpointRejected",
        { text = " ", texthl = "DiagnosticError", priority = 1000 }
      ) -- 被拒绝的断点（无效断点）
      vim.fn.sign_define("DapLogPoint", { text = ".>", texthl = "DiagnosticInfo" }) -- 日志点
    end,

    -- 核心调试功能的快捷键映射
    keys = {
      {
        "<leader>db",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "切换断点 (Toggle Breakpoint)",
      },
      {
        "<leader>dc",
        function()
          require("dap").continue()
        end,
        desc = "开始/继续运行 (Run/Continue)",
      },
      {
        "<leader>dC",
        function()
          require("dap").run_to_cursor()
        end,
        desc = "运行到光标处 (Run to Cursor)",
      },
      {
        "<leader>dg",
        function()
          require("dap").goto_()
        end,
        desc = "跳转到行但不执行 (Go to Line)",
      },
      {
        "<leader>di",
        function()
          require("dap").step_into()
        end,
        desc = "单步进入 (Step Into)", -- 进入函数内部
      },
      {
        "<leader>dj",
        function()
          require("dap").down()
        end,
        desc = "调用栈向下移动 (Stack Down)",
      },
      {
        "<leader>dk",
        function()
          require("dap").up()
        end,
        desc = "调用栈向上移动 (Stack Up)",
      },
      {
        "<leader>dl",
        function()
          require("dap").run_last()
        end,
        desc = "重新运行上一次调试 (Run Last)",
      },
      {
        "<leader>do",
        function()
          require("dap").step_out()
        end,
        desc = "单步跳出 (Step Out)", -- 执行完当前函数并返回
      },
      {
        "<leader>dO",
        function()
          require("dap").step_over()
        end,
        desc = "单步跳过 (Step Over)", -- 执行下一行，不进入函数
      },
      {
        "<leader>dP",
        function()
          require("dap").pause()
        end,
        desc = "暂停 (Pause)",
      },
      {
        "<leader>ds",
        function()
          require("dap").session()
        end,
        desc = "查看当前会话 (Session)",
      },
      {
        "<leader>dt",
        function()
          require("dap").terminate()
        end,
        desc = "终止调试 (Terminate)",
      },
      {
        "<leader>dw",
        function()
          require("dap.ui.widgets").hover()
        end,
        desc = "查看变量详情 (Widgets Hover)", -- 类似于鼠标悬停查看值
      },
      {
        "<leader>dB",
        function()
          require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
        end,
        desc = "设置条件断点 (Condition Breakpoint)",
      },
    },
  },

  -- ========================================================================
  -- 2. nvim-dap-view: 调试界面 UI
  -- ========================================================================
  {
    "igorlfs/nvim-dap-view",
    keys = {
      {
        "<leader>du",
        function()
          require("dap-view").toggle()
        end,
        desc = "切换调试界面显示 (Toggle UI)",
      },
      {
        "<leader>de",
        function()
          require("dap-view").add_expr()
        end,
        desc = "添加监视表达式 (Watch Expression)",
        mode = { "n", "x" }, -- 支持普通模式和可视模式
      },
    },
    opts = {
      -- 窗口栏配置
      winbar = {
        controls = { enabled = true }, -- 启用播放/暂停等控制按钮
        -- 界面中显示的板块
        sections = {
          "watches",
          "exceptions",
          "breakpoints",
          "scopes",
          "threads",
          "repl",
          "console",
        },
      },
    },
    config = function(_, opts)
      local dap = require("dap")
      local dap_view = require("dap-view")

      -- 初始化 UI
      dap_view.setup(opts)

      -- 设置事件监听器：实现自动化 UI 行为

      -- 当调试初始化完成后，自动打开 UI 界面
      dap.listeners.after.event_initialized["dap-view-config"] = function()
        dap_view.open()
      end

      -- 当调试终止时，自动关闭 UI 界面
      dap.listeners.before.event_terminated["dap-view-config"] = function()
        dap_view.close()
      end

      -- 当调试退出时，自动关闭 UI 界面
      dap.listeners.before.event_exited["dap-view-config"] = function()
        dap_view.close()
      end
    end,
  },
}
