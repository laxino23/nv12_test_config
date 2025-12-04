local source = {
  default = { "supermaven", "lsp", "path", "snippets", "buffer" },

  providers = {
    -- 1. Supermaven (AI 补全)
    supermaven = {
      name = "supermaven",
      module = "blink.compat.source",
      score_offset = 100,
      async = true,
    },

    -- 2. LSP (语言服务器)
    lsp = {
      fallbacks = { "buffer" },
    },

    -- 3. Path (文件路径)
    path = {
      score_offset = 3,
      opts = {
        trailing_slash = false,
        label_trailing_slash = true,
        get_cwd = function(context)
          return vim.fn.expand(("#%d:p:h"):format(context.bufnr or 0))
        end,
        show_hidden_files_by_default = true,
      },
    },

    -- 4. Buffer (当前缓冲区文本)
    buffer = {
      min_keyword_length = 2,
    },

    -- 5. Snippets (代码片段)
    snippets = {
      score_offset = 1000,
      should_show_items = function(ctx)
        return ctx.trigger.initial_kind ~= "trigger_character"
      end,
    },

    -- 6. Cmdline (命令行)
    cmdline = {
      name = "cmdline",
      module = "blink.cmp.sources.cmdline",
    },

    -- 7. Thesaurus (同义词库 - 需要 blink-cmp-words 插件)
    thesaurus = {
      name = "blink-cmp-words",
      module = "blink-cmp-words.thesaurus",
      opts = {
        score_offset = 0,
        definition_pointers = { "!", "&", "^" },
        similarity_pointers = { "&", "^" },
        similarity_depth = 2,
      },
    },

    -- 8. Dictionary (字典 - 需要 blink-cmp-words 插件)
    dictionary = {
      name = "blink-cmp-words",
      module = "blink-cmp-words.dictionary",
      opts = {
        dictionary_search_threshold = 3,
        score_offset = 0,
        definition_pointers = { "!", "&", "^" },
      },
    },
  },

  -- 针对特定文件类型的源配置
  per_filetype = {
    text = { "supermaven", "dictionary", "buffer", "path" },
    markdown = { "supermaven", "thesaurus", "dictionary", "snippets", "buffer", "path" },
    typst = { "supermaven", "lsp", "snippets", "dictionary", "path" },
    tex = { "supermaven", "lsp", "dictionary", "thesaurus", "path", "snippets" },
  },
}

return { source = source }
