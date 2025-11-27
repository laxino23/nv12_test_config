return {
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        sections = {
            {
              section = "terminal",
              cmd = "RUBYOPT='-W0' lolcat --seed=24 ~/.config/nv12/static/neovim.cat",
              indent = 5,
              height = 8,
              width = 69,
              padding = 1,
            },
            {
              section = "keys",
              indent = 1,
              padding = 1,
            },
            { section = "startup" },
        },
      },
    },
  },
}
