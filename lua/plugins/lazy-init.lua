-- ~/.config/nvim/lua/plugins/init.lua

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
        vim.fn.system({
                "git",
                "clone",
                "--filter=blob:none",
                "https://github.com/folke/lazy.nvim.git",
                "--branch=stable",
                lazypath,
        })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
        -- My Own Plugins LOl
        { import = "plugins.idleCLock" },

        { import = "plugins.splits" },
        -- List your plugins here, or require separate files
        -- For WebCodeBases
        { import = "plugins.meow-yarn" },
        { import = "plugins.arrow-navigation" },
        -- For webDevelopment
        { import = "plugins.nvim-html-css" },
        { import = "plugins.autoclose-tag" },
        -- { import = "plugins.telescope" },
        -- {import = "plugins.rustaceanvim"},
        { import = "plugins.whichKey" },
        { import = "plugins.conform" },
        -- For Speed
        { import = "plugins.luaSnip" },

        { import = "plugins.vim-visual-multi" },

        { import = "plugins.neogen" },
        { import = "plugins.fzf" },
        -- {import = "plugins.inputSnacks"},
        { import = "plugins.lazyGit" },
        { import = "plugins.alternate-toggle" },
        -- { import = "plugins.telescope-browser" },
        -- { import = "plugins.telescope-fzf-native" },
        { import = "plugins.treesitter" },
        -- Add other plugins...
        { import = "plugins.persistence" },
        { import = "plugins.oil" },
        -- { import = "plugins.catppuccin"},
        -- { import = "dashboard.dashboard" },
        { import = "plugins.snacks" },
        { import = "plugins.nvim-bqf" },
        -- { import = "plugins.notify" },
        -- For LSP Managements
        { import = "plugins.lspconfig" },
        { import = "plugins.csharplsp" },
        -- For Debuggers
        { import = "plugins.debugger" },
        { import = "plugins.comment" },
        { import = "plugins.webdevicons" },
        { import = "plugins.rosepinemoon" },
        { import = "plugins.toggleterm" },

        { import = "plugins.neotest" },
        -- { import = "plugins.lspSignature" },
        { import = "plugins.dev" },
        { import = "plugins.rainbow" },
        { import = "plugins.autoclose" },
        -- { import = "plugins.tabout" },
        -- { import = "plugins.neogit" },
        { import = "plugins.lualine" },
        -- { import = "plugins.lspSignature" },
        { import = "plugins.dev" },
        { import = "plugins.rainbow" },
        { import = "plugins.autoclose" },
        -- { import = "plugins.tabout" },
        { import = "plugins.miniMove" },
        -- { import = "plugins.neogit" },
        { import = "plugins.lualine" },
        { import = "plugins.treesitter-textObjects" },
        { import = "plugins.bufferline" },
        { import = "plugins.mini-line" },
        -- Navigations
        { import = "plugins.before" },
        { import = "plugins.flash" },
        { import = "plugins.import" },
        { import = "plugins.precognition" },
        -- { import = "plugins.helpers_plugin"}
        { import = "plugins.text-objets" },

        -- { import = "plugins.indent-blankline" },
        -- { import = "plugins.none" },
        { import = "plugins.diffview" },
        { import = "plugins.cmd" },
        { import = "plugins.grug-far" },
        { import = "plugins.obsidian" },
        { import = "plugins.mini-files" },
        -- { import = "plugins.nvim-spectre" },
        { import = "plugins.nvim-dbview" },

        -- Mini plugins
        { import = "miniPlugins.mini-ai" },
        { import = "plugins.cmp" },
})

-- color Scheme catppuccin
-- vim.cmd.colorscheme("catppuccin-mocha") -- or "catppuccin-mocha", "catppuccin-frappe", etc.
