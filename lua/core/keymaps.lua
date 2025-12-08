-- ~/.config/nvim/lua/core/keymaps.lua

-- Obsidian Keymaps

vim.keymap.set("n", "<leader>oe", function()
        local ft = Buf.ft() -- your helper

        local template_map = {
                lua = "lua",
                python = "python",
                javascript = "js",
                typescript = "ts",
                markdown = "default",
        }

        local template = template_map[ft] or "default"

        -- Ask for title
        local title = vim.fn.input("Note title: ")

        -- Call Obsidian with explicit template
        vim.cmd(string.format("Obsidian new_from_template %s %s", title, template))
end, { desc = "New Obsidian note from filetype template" })

vim.keymap.set("n", "<leader>oc", function()
        vim.cmd("Obsidian new_from_template")
end, { desc = "Obsidian: New Note From buffer's Current language" })

vim.keymap.set("n", "<leader>oC", function()
        vim.cmd("Obsidian new")
end, { desc = "Obsidian: Create new note (API)" })
vim.keymap.set("n", "<leader>ob", function()
        vim.cmd("Obsidian quick_switch")
end, { desc = "Obsidian: quick_switch" })

vim.keymap.set("n", "<leader>og", function()
        vim.cmd("Obsidian search")
end, { desc = "Obsidian:  Search Notes" })

-- better up/down
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

-- buffers
vim.keymap.set("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
vim.keymap.set("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
vim.keymap.set("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer" })
vim.keymap.set("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
vim.keymap.set("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
vim.keymap.set("n", "<leader>bd", function()
        Snacks.bufdelete()
end, { desc = "Delete Buffer" })
vim.keymap.set("n", "<leader>bo", function()
        Snacks.bufdelete.other()
end, { desc = "Delete Other Buffers" })
vim.keymap.set("n", "<leader>bD", "<cmd>:bd<cr>", { desc = "Delete Buffer and Window" })

-- save file
vim.keymap.set({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File" })

-- location list
vim.keymap.set("n", "<leader>xl", function()
        local success, err = pcall(vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen)
        if not success and err then
                vim.notify(err, vim.log.levels.ERROR)
        end
end, { desc = "Location List" })

-- quickfix list
vim.keymap.set("n", "<leader>xq", function()
        local success, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
        if not success and err then
                vim.notify(err, vim.log.levels.ERROR)
        end
end, { desc = "Quickfix List" })

vim.keymap.set("n", "[q", vim.cmd.cprev, { desc = "Previous Quickfix" })
vim.keymap.set("n", "]q", vim.cmd.cnext, { desc = "Next Quickfix" })

local function project_root()
        local root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
        if root and root ~= "" then
                return root
        end
        return vim.loop.cwd()
end

-- floating terminal
vim.keymap.set("n", "<leader>fT", function()
        Snacks.terminal()
end, { desc = "Terminal (cwd)" })
vim.keymap.set("n", "<leader>ft", function()
        Snacks.terminal(nil, { cwd = project_root() })
end, { desc = "Terminal (Root Dir)" })

vim.keymap.set({ "n", "t" }, "<c-/>", function()
        Snacks.terminal(nil, { cwd = project_root() })
end, { desc = "Terminal (Root Dir)" })
vim.keymap.set({ "n", "t" }, "<c-_>", function()
        Snacks.terminal(nil, { cwd = project_root() })
end, { desc = "which_key_ignore" })

vim.keymap.set("n", "<leader>on", "<CMD>Nvumi<CR>", { desc = "[O]pen [N]vumi" })

-- lua
-- vim.keymap.set({ "n", "x" }, "<localleader>rc", function()
--         Snacks.debug.run()
-- end, { desc = "Run Lua", ft = "lua" })

-- ================================
-- Duplicate like VS Code (Alt+Shift)
-- ================================

-- =====================================
-- Duplicate with Alt+Shift+hjkl (Clean)
-- =====================================

-- NORMAL MODE
vim.keymap.set("n", "<A-S-j>", "yyp", { noremap = true, silent = true }) -- down
vim.keymap.set("n", "<A-S-k>", "yyP", { noremap = true, silent = true }) -- up

-- VISUAL MODE
vim.keymap.set("v", "<A-S-j>", ":t'>+1<CR>gv", { noremap = true, silent = true })
vim.keymap.set("v", "<A-S-k>", ":t'<-1<CR>gv", { noremap = true, silent = true })

-- ============================================
-- Horizontal Duplicate (Alt+Shift+h / l)
-- Word & Visual Selection with auto-space
-- ============================================

-- NORMAL MODE: duplicate word under cursor

-- Duplicate to the RIGHT
vim.keymap.set("n", "<A-S-l>", function()
        local word = vim.fn.expand("<cword>")
        if word == "" then
                return
        end
        vim.cmd("normal! e")
        vim.api.nvim_put({ " " .. word }, "c", true, true)
end, { noremap = true, silent = true })

-- Duplicate to the LEFT
vim.keymap.set("n", "<A-S-h>", function()
        local word = vim.fn.expand("<cword>")
        if word == "" then
                return
        end
        vim.cmd("normal! b")
        vim.api.nvim_put({ word .. " " }, "c", false, true)
end, { noremap = true, silent = true })

-- VISUAL MODE: duplicate exact selection

-- Duplicate selection to the RIGHT
vim.keymap.set("v", "<A-S-l>", function()
        local text = table.concat(vim.fn.getregion(vim.fn.getpos("'<"), vim.fn.getpos("'>")), "\n")
        vim.cmd("normal! `>a ")
        vim.api.nvim_put({ text }, "c", true, true)
end, { noremap = true, silent = true })

-- Duplicate selection to the LEFT
vim.keymap.set("v", "<A-S-h>", function()
        local text = table.concat(vim.fn.getregion(vim.fn.getpos("'<"), vim.fn.getpos("'>")), "\n")
        vim.cmd("normal! `<i")
        vim.api.nvim_put({ text .. " " }, "c", false, true)
end, { noremap = true, silent = true })

-- source lua file
vim.keymap.set("n", "<leader>ls", function()
        -- checks if buffer is modified, if it is then write it
        local buf = vim.api.nvim_get_current_buf()
        local is_modified = vim.api.nvim_get_option_value("modified", { buf = buf })

        if is_modified == true then
                vim.cmd("w")
        end
        vim.cmd("luafile " .. vim.fn.expand("%"))
        vim.notify("loaded")
end, { desc = "Source current Lua file" })

-- -- live liveserver
-- vim.keymap.set("n", "<leader>lss", ":!live-server .<CR>", { desc = "Start live-server" })

-- LSP
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "LSP Rename" })
vim.keymap.set("v", "<leader>la", vim.lsp.buf.code_action, { desc = "LSP Action" })
-- refractor nvim

vim.keymap.set("v", "<leader>rf", function()
        require("refactoring").select_refactor()
end, { desc = "Refactor (select)" })
-- to read Python docs

vim.keymap.set("n", "<leader>fd", function()
        Snacks.picker.grep({
                cwd = vim.fn.expand("~/docs/python-3.14-docs-text"),
                glob = { "library/**", "reference/**", "tutorial/**" },
                prompt_title = "Python Docs",
        })
end)

-- Noetest keymaps
local neotest = require("neotest")

vim.keymap.set("n", "<leader>tn", function()
        neotest.run.run() -- run nearest test
end)

vim.keymap.set("n", "<leader>tf", function()
        neotest.run.run(vim.fn.expand("%")) -- run current file
end)

vim.keymap.set("n", "<leader>ts", function()
        neotest.summary.toggle() -- toggle summary panel
end)

vim.keymap.set("n", "<leader>to", function()
        neotest.output.open({ enter = true }) -- open test output
end)

vim.keymap.set("n", "<leader>tl", function()
        neotest.run.run_last() -- rerun last test
end)
-- To delete buffers
-- Safe close current buffer
vim.keymap.set("n", "<leader>qq", function()
        require("snacks").bufdelete()
end)
-- toggleTerm
-- ToggleTerm Send-to-Terminal Keymaps
local trim_spaces = true
local toggleterm = require("toggleterm")

vim.keymap.set("n", "<leader>cd", function()
        local buf_path = vim.api.nvim_buf_get_name(0)
        if buf_path == "" then
                vim.notify("No file path detected", vim.log.levels.WARN)
                return
        end

        local dir = vim.fn.fnamemodify(buf_path, ":p:h")
        local cmd = "cd " .. vim.fn.shellescape(dir)

        -- Send only the cd command to terminal
        require("toggleterm").send_lines_to_terminal("single_line", true, {
                lines = { cmd },
        })

        -- Notify inside Neovim only (not sent to terminal)
        vim.notify("Sent to terminal: " .. cmd, vim.log.levels.INFO)
end, { desc = "Send buffer directory as cd to terminal" })

vim.keymap.set("n", "<leader>tp", function()
        local clipboard = vim.fn.getreg("+")
        if clipboard and clipboard ~= "" then
                require("toggleterm").send_lines_to_terminal("single_line", true, {
                        lines = { clipboard },
                        args = vim.v.count,
                })
        else
                vim.notify("Clipboard is empty", vim.log.levels.WARN)
        end
end, { desc = "Send clipboard text to terminal" })
-- Visual mode: Send selected lines (choose mode: "single_line", "visual_lines", or "visual_selection")
vim.keymap.set("v", "<space>s", function()
        toggleterm.send_lines_to_terminal("visual_selection", trim_spaces, { args = vim.v.count })
end, { desc = "Send visual selection to terminal" })

-- Operator-pending: Send motion to terminal
vim.keymap.set("n", "<leader><c-\\>", function()
        set_opfunc(function(motion_type)
                toggleterm.send_lines_to_terminal(motion_type, trim_spaces, { args = vim.v.count })
        end)
        vim.api.nvim_feedkeys("g@", "n", false)
end, { desc = "Send motion to terminal" })

-- Normal mode: Send current line to terminal
vim.keymap.set("n", "<leader><c-\\><c-\\>", function()
        set_opfunc(function(motion_type)
                toggleterm.send_lines_to_terminal(motion_type, trim_spaces, { args = vim.v.count })
        end)
        vim.api.nvim_feedkeys("g@_", "n", false)
end, { desc = "Send current line to terminal" })

-- Normal mode: Send entire file to terminal
vim.keymap.set("n", "<leader><leader><c-\\>", function()
        set_opfunc(function(motion_type)
                toggleterm.send_lines_to_terminal(motion_type, trim_spaces, { args = vim.v.count })
        end)
        vim.api.nvim_feedkeys("ggg@G''", "n", false)
end, { desc = "Send entire file to terminal" })

-- command line testing
-- Lua (init.lua)
-- lua print(vim.inspect(require("before")))
vim.keymap.set("v", "<leader>xr", function()
        local cmd = table.concat(vim.fn.getline("'<", "'>"), "\n")
        vim.cmd(cmd)
end, { desc = "Execute selected text as command" })

-- Lua
-- vim.keymap.set("n", "x", require("substitute").operator, { noremap = true }) -- like yi{ then xi{
-- vim.keymap.set("n", "xl", require("substitute").line, { noremap = true }) -- after yanking line, then xl
-- vim.keymap.set("n", "X", require("substitute").eol, { noremap = true }) -- pastes then removes other stuff till eol
-- vim.keymap.set("x", "x", require("substitute").visual, { noremap = true }) -- removes the selection, pastes the yank
--
-- vim.keymap.set("n", "<leader>x", require("substitute.exchange").operator, { noremap = true })
-- vim.keymap.set("x", "<leader>x", require("substitute.exchange").visual, { noremap = true })
-- vim.keymap.set("n", "<leader>X", require("substitute.exchange").line, { noremap = true })
