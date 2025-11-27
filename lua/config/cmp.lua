local M = {}
---@type function?, function?
-- 定义两个局部变量用于缓存函数。
-- 这样做是为了性能优化：只在第一次运行时检测使用哪个图标库，
-- 之后直接调用缓存好的函数，避免每次渲染列表项都重新判断。
local icon_provider, hl_provider

-- 主函数：接收一个上下文对象 CTX (包含当前补全项的信息)
local function get_kind_icon(CTX)
  -- ==========================================================
  -- 1. 图标提供者逻辑 (Icon Provider)
  --    判断应该使用 mini.icons 还是 lspkind
  -- ==========================================================
  
  -- 尝试加载 mini.icons 插件
  local _, mini_icons = pcall(require, "mini.icons")
  
  -- 如果全局变量 vim.g.kind_icons 设置为 "mini"
  if vim.g.kind_icons == "mini" then
    -- 定义 icon_provider 具体逻辑
    icon_provider = function(ctx)
      -- 检查当前的高亮是否已经是特定的颜色值 (比如 #FF0000 这种 HexColor)
      -- 如果是，后面就不应该用通用的图标颜色覆盖它
      local is_specific_color = ctx.kind_hl and ctx.kind_hl:match("^HexColor") ~= nil
      
      -- 情况 A: 如果补全来源是 LSP (语言服务器)
      if ctx.item.source_name == "LSP" then
        -- 从 mini.icons 获取对应的图标和高亮组
        local icon, hl = mini_icons.get("lsp", ctx.kind or "")
        if icon then
          ctx.kind_icon = icon
          -- 只有当它不是特定的颜色代码时，才应用 mini.icons 的默认高亮
          if not is_specific_color then
            ctx.kind_hl = hl
          end
        end
        
      -- 情况 B: 如果补全来源是 Path (文件路径)
      elseif ctx.item.source_name == "Path" then
        -- 根据类型是 Folder (目录) 还是 file (文件) 来获取图标
        -- ctx.label 通常是文件名，mini.icons 会根据扩展名返回准确的图标
        ctx.kind_icon, ctx.kind_hl = mini_icons.get(ctx.kind == "Folder" and "directory" or "file", ctx.label)
        
      -- 情况 C: 如果补全来源是 Snippets (代码片段)
      elseif ctx.item.source_name == "Snippets" then
        ctx.kind_icon, ctx.kind_hl = mini_icons.get("lsp", "snippet")
      end
    end
  end

  -- 如果全局变量 vim.g.kind_icons 设置为 "lspkind"
  if vim.g.kind_icons == "lspkind" then
    local lspkind_avail, lspkind = pcall(require, "lspkind")
    if lspkind_avail then
      -- 定义基于 lspkind 的逻辑
      icon_provider = function(ctx)
        if ctx.item.source_name == "LSP" then
          -- 使用 lspkind 获取符号
          local icon = lspkind.symbolic(ctx.kind, { mode = "symbol" })
          if icon then
            ctx.kind_icon = icon
          end
        elseif ctx.item.source_name == "Snippets" then
          local icon = lspkind.symbolic("Snippet", { mode = "symbol" })
          if icon then
            ctx.kind_icon = icon
          end
        end
      end
    end
  end

  -- 如果上面都没匹配到（比如没装插件），给一个空函数防止报错
  if not icon_provider then
    icon_provider = function() end
  end

  -- ==========================================================
  -- 2. 高亮提供者逻辑 (Highlight Provider)
  --    专门处理颜色代码的预览 (Color Preview)
  -- ==========================================================
  
  -- 如果还没有初始化 hl_provider
  if not hl_provider then
    -- 尝试加载 nvim-highlight-colors 插件
    local highlight_colors_avail, highlight_colors = pcall(require, "nvim-highlight-colors")
    
    if highlight_colors_avail then
      local kinds
      hl_provider = function(ctx)
        -- 延迟加载 blink.cmp 的类型定义
        if not kinds then
          kinds = require("blink.cmp.types").CompletionItemKind
        end
        
        -- 核心逻辑：如果当前补全项的类型是 "Color" (颜色)
        if ctx.item.kind == kinds.Color then
          -- 获取文档内容 (通常文档里包含实际的颜色值，如 #ff0000)
          local doc = vim.tbl_get(ctx, "item", "documentation")
          if doc then
            -- 调用 highlight_colors 插件生成动态的高亮组
            local color_item = highlight_colors_avail and highlight_colors.format(doc, { kind = kinds[kinds.Color] })
            
            -- 如果成功生成了颜色信息
            if color_item and color_item.abbr_hl_group then
              -- 如果有缩写字符(abbr)，用它替换图标（变成一个有颜色的小方块）
              if color_item.abbr then
                ctx.kind_icon = color_item.abbr
              end
              -- 将高亮组应用到图标上
              ctx.kind_hl = color_item.abbr_hl_group
            end
          end
        end
      end
    end
    
    -- 兜底：如果没有该插件，给个空函数
    if not hl_provider then
      hl_provider = function() end
    end
  end

  -- ==========================================================
  -- 3. 执行与返回
  -- ==========================================================
  
  -- 调用上面根据环境“懒加载”好的处理函数
  icon_provider(CTX)
  hl_provider(CTX)
  
  -- 返回最终结果给 blink.cmp 渲染
  -- text: 图标 + 间距
  -- highlight: 图标的高亮组名称
  return { text = CTX.kind_icon .. CTX.icon_gap, highlight = CTX.kind_hl }
end

M.get_kind_icon = get_kind_icon

return M
