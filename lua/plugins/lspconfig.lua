return { -- Main LSP Configuration
        "neovim/nvim-lspconfig",
        dependencies = {
                -- Automatically install LSPs and related tools to stdpath for Neovim
                -- Mason must be loaded before its dependents so we need to set it up here.
                -- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
                { "mason-org/mason.nvim", opts = {} },
                "mason-org/mason-lspconfig.nvim",
                "WhoIsSethDaniel/mason-tool-installer.nvim",

                -- Useful status updates for LSP.
                { "j-hui/fidget.nvim", opts = {} },

                -- Allows extra capabilities provided by blink.cmp
        },
        config = function()
                -- local capabilities = require("blink.lsp").default_capabilities()

                local util = require("lspconfig.util")

                local lspconfig = require("lspconfig")

                local root_files = {
                        ".luarc.json",
                        ".luarc.jsonc",
                        ".luacheckrc",
                        ".stylua.toml",
                        ".git",
                        "stylua.toml",
                        "selene.toml",
                        "selene.yml",
                }

                local servers = {
                        lua_ls = {
                                root_markers = {
                                        ".luarc.json",
                                        ".luarc.jsonc",
                                        ".luacheckrc",
                                        ".stylua.toml",
                                        ".git",
                                        ".github",
                                        "stylua.toml",
                                        "selene.toml",
                                        "selene.yml",
                                },
                                -- on_attach = function(client, bufnr)
                                --         local bufname = vim.api.nvim_buf_get_name(bufnr)
                                --         -- if bufname:match("Luapad") or bufname:match("luapad.nvim") then
                                --         --         vim.schedule(function()
                                --         --                 client.stop()
                                --         --                 vim.notify(
                                --         --                         "Detached lua_ls from Luapad buffer",
                                --         --                         vim.log.levels.INFO
                                --         --                 )
                                --         --         end)
                                --         --         return
                                --         -- end
                                --
                                --         local lazy_root = vim.fn.stdpath("data") .. "/lazy"
                                --         if bufname:find(lazy_root, 1, true) then
                                --                 -- Derive Plugin folder as root
                                --                 local plugin_root = vim.fs.dirname(bufname:sub(#lazy_root + 2))
                                --                 plugin_root = lazy_root .. "/" .. plugin_root:match("^[^/]+")
                                --
                                --                 client.stop()
                                --
                                --                 -- Re‑enable lua_ls with plugin_root as root_dir
                                --                 vim.lsp.config("lua_ls", {
                                --                         root_dir = plugin_root,
                                --                         settings = {
                                --                                 Lua = {
                                --                                         runtime = { version = "LuaJit" },
                                --                                         diagnostics = { globals = { "vim" } },
                                --                                         type = {
                                --                                                 checkTableShape = true,
                                --                                         },
                                --                                         workspace = { checkThirdParty = false },
                                --                                 },
                                --                         },
                                --                 })
                                --                 vim.lsp.enable("lua_ls")
                                --
                                --                 -- Change cwd for convenience
                                --                 vim.cmd("cd " .. plugin_root)
                                --                 vim.notify(
                                --                         "lua_ls reattached with root: " .. plugin_root,
                                --                         vim.log.levels.INFO
                                --                 )
                                --                 return
                                --         end
                                --         -- Normal attach logic here (if needed)
                                -- end,
                                single_file_support = true,
                                cmd = { "lua-language-server" },

                                settings = {
                                        Lua = {
                                                runtime = {
                                                        version = "LuaJit",
                                                },
                                                diagnostics = {
                                                        globals = { "vim" },
                                                },
                                                workspace = {
                                                        checkThirdParty = false,
                                                        ignoreDir = { vim.fn.stdpath("data") .. "/lazy" },
                                                },
                                        },
                                },
                        },

                        -- pyright = {
                        --         single_file_support = true,
                        --         settings = {
                        --                 python = {
                        --                         analysis = {
                        --                                 autoSearchPaths = true,
                        --                                 useLibraryCodeForTypes = true,
                        --
                        --                                 -- 🔥 THIS IS WHAT WILL CATCH `.length`
                        --                                 typeCheckingMode = "strict",
                        --
                        --                                 -- Optional but very useful:
                        --                                 diagnosticMode = "workspace",
                        --                         },
                        --                 },
                        --         },
                        -- },
                        -- Add more servers here if needed
                        -- tsserver = {},
                        -- jsonls = {},
                }

                for server, config in pairs(servers) do
                        vim.lsp.config(server, config)
                        -- vim.lsp.enable(server)
                end
                require("mason-lspconfig").setup({
                        ensure_installed = { "lua_ls" },
                })

                -- actually apply configs
                -- for server, config in pairs(servers) do
                --         lspconfig[server].setup(config)
                -- end

                require("mason-tool-installer").setup({
                        ensure_installed = {
                                "stylua", -- this installs the CLI formatter
                        },
                })

                -- Define a custom command
                vim.api.nvim_create_user_command("LuaRoot", function(opts)
                        local fname = vim.api.nvim_buf_get_name(0)
                        local current_root = vim.lsp.get_clients({ name = "lua_ls" })[1]
                                and vim.lsp.get_clients({ name = "lua_ls" })[1].config.root_dir

                        -- Prompt the user to pick a root
                        vim.ui.select({
                                -- -- util.path.dirname(fname), -- just the file’s folder
                                vim.fs.dirname(fname),
                                current_root, -- whatever lua_ls currently thinks
                                vim.fn.getcwd(), -- your current working dir
                        }, { prompt = "Pick root for lua_ls:" }, function(choice)
                                if choice then
                                        -- Stop existing client
                                        for _, client in ipairs(vim.lsp.get_clients({ name = "lua_ls" })) do
                                                client:stop()
                                        end
                                        -- Re‑enable with new root
                                        vim.lsp.config("lua_ls", {
                                                root_dir = choice,
                                                settings = {
                                                        Lua = {
                                                                runtime = { version = "LuaJit" },
                                                                diagnostics = { globals = { "vim" } },
                                                                workspace = { checkThirdParty = false },
                                                        },
                                                },
                                        })
                                        vim.lsp.enable("lua_ls")
                                        vim.notify("lua_ls reattached with root: " .. choice, vim.log.levels.INFO)
                                end
                        end)
                end, { nargs = 0 })
        end,
}
