-- ~/.config/nvim/lua/core/keymaps.lua

-- Obsidian Keymaps

vim.keymap.set("n", "<leader>oe", function()
        local ft = M.ft() -- your helper

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

-- vim.keymap.set("n", "<leader>ug", function()
--         local win = vim.api.nvim_get_current_win()
--
--         local number = vim.wo[win].number
--         local relativenumber = vim.wo[win].relativenumber
--         local signcolumn = vim.wo[win].signcolumn
--
--         if number or relativenumber or signcolumn ~= "no" then
--                 vim.wo[win].number = false
--                 vim.wo[win].relativenumber = false
--                 vim.wo[win].signcolumn = "no"
--         else
--                 vim.wo[win].number = true
--                 vim.wo[win].relativenumber = true
--                 vim.wo[win].signcolumn = "yes"
--         end
-- end, { desc = "Toggle gutter (numbers + signs)" })

vim.keymap.set("n", "<leader>ug", function()
        local wins = vim.api.nvim_list_wins()

        -- decide toggle state from current window
        local cur = vim.api.nvim_get_current_win()
        local enable = not (vim.wo[cur].number or vim.wo[cur].relativenumber or vim.wo[cur].signcolumn ~= "no")

        for _, win in ipairs(wins) do
                vim.wo[win].number = enable
                vim.wo[win].relativenumber = enable
                vim.wo[win].signcolumn = enable and "yes" or "no"
        end
end, { desc = "Toggle gutter (all windows)" })

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

local function current_file_parent()
        local bufname = vim.api.nvim_buf_get_name(0)
        if bufname == "" then
                return vim.loop.cwd() -- fallback if buffer has no file
        end
        return vim.fn.fnamemodify(bufname, ":h")
end

-- floating terminal
-- vim.keymap.set("n", "<leader>ft", function()
--         Snacks.terminal()
-- end, { desc = "Terminal (cwd)" })
vim.keymap.set("n", "<leader>ft", function()
        Snacks.terminal(nil, { cwd = current_file_parent() })
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
vim.keymap.set("n", "gI", vim.lsp.buf.implementation, { desc = "LSP implementation" })
vim.keymap.set("n", "lr", vim.lsp.buf.references, { desc = "LSP refrence" })
vim.keymap.set("n", "lt", vim.lsp.buf.type_definition, { desc = "LSP type_definition" })
vim.keymap.set("n", "gd", vim.lsp.buf.definition, {
        desc = "Go to definition",
})

vim.keymap.set("n", "<leader>ts", function()
        require("symbol-usage").toggle()
end, { desc = "Description" })

-- vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = true })

local function smart_python_hover()
        local clients = vim.lsp.get_clients({ bufnr = 0 })

        for _, client in ipairs(clients) do
                if client.name == "jedi_language_server" then
                        vim.lsp.buf.hover({
                                filter = function(c)
                                        return c.name == "jedi_language_server"
                                end,
                        })
                        return
                end
        end

        -- fallback to pyright
        vim.lsp.buf.hover({
                filter = function(c)
                        return c.name == "basedpyright"
                end,
        })
end

-- vim.api.nvim_create_autocmd("FileType", {
--         pattern = "python",
--         callback = function(ev)
--                 vim.keymap.set("n", "K", smart_python_hover, { buffer = ev.buf })
--         end,
-- })

Snacks.keymap.set("n", "K", smart_python_hover, { ft = { "python" }, desc = "python hover" })
Snacks.keymap.set(
        "n",
        "<leader>gI",
        vim.lsp.buf.type_definition,
        { ft = { "python" }, desc = "Pyright: Go to implementation" }
)

-- local function jedi_hover()
--         vim.lsp.buf.hover({
--                 filter = function(client)
--                         return client.name == "jedi_language_server"
--                 end,
--         })
-- end
--
-- vim.api.nvim_create_autocmd("FileType", {
--         pattern = "python",
--         callback = function(ev)
--                 vim.keymap.set("n", "K", jedi_hover, { buffer = ev.buf })
--         end,
-- })

-- local function pyright_hover()
--         vim.lsp.buf.hover({
--                 filter = function(client)
--                         return client.name == "basedpyright"
--                 end,
--         })
-- end
--
-- vim.api.nvim_create_autocmd("FileType", {
--         pattern = "python",
--         callback = function(ev)
--                 vim.keymap.set("n", "K", pyright_hover, { buffer = ev.buf, silent = true })
--         end,
-- })

-- vim.keymap.set("n", "K", function()
--   local clients = vim.lsp.get_clients({ bufnr = 0 })
--   if #clients > 0 then
--     vim.lsp.buf.hover()
--   else
--     vim.cmd("normal! K")
--   end
-- end, { desc = "Hover (LSP or fallback)" })
--
-- smartActions

---@diagnostic disable-next-line: undefined-global
local last_created_word = last_created_word or ""

-- create a highlight group
local ns = vim.api.nvim_create_namespace("last_created_word")

vim.api.nvim_set_hl(0, "LastCreatedWord", {
        fg = "#ff79c6",
        bg = "#2a2a37",
        bold = true,
})

vim.api.nvim_set_hl(0, "LastCreatedWordAlt", {
        fg = "#7dcfff", -- icy blue / teal
        bg = "#1f2a33", -- dark blue-gray
        bold = true,
})

local function highlight_word(color_group, word)
        if word == nil then
                return
        end
        local bufnr = vim.api.nvim_get_current_buf()

        -- clear previous highlight (only once rule)
        vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

        -- cursor position (1-based row, 0-based col)
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        row = row - 1

        -- calculate word start column
        local start_col = col - #word + 1
        if start_col < 0 then
                return
        end

        vim.api.nvim_buf_add_highlight(
                bufnr,
                ns,
                "LastCreatedWord", -- or your custom hl group
                row,
                start_col,
                start_col + #word
        )
end
vim.api.nvim_create_autocmd("InsertLeave", {
        callback = function()
                local word = vim.fn.expand("<cword>")
                if word and word ~= "" then
                        last_created_word = word
                        -- vim.notify(last_created_word)
                        highlight_word("LastCreatedWord")
                end
        end,
})
vim.keymap.set("n", "<leader>gw", function()
        local word = last_created_word
        if word == "" then
                vim.notify("No word remembered yet", vim.log.levels.WARN)
                return
        end

        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        local line = vim.api.nvim_get_current_line()
        local char = line:sub(col + 1, col + 1)

        -- keyword characters: letters, numbers, underscore
        if char:match("[%w_]") then
                -- replace word
                vim.cmd("normal! ciw" .. word)
        else
                -- insert at cursor
                vim.cmd("normal! i" .. word)
        end
end, {
        desc = "Replace word or insert last created identifier",
})

---@diagnostic disable-next-line: undefined-global
local last_typed_word = local_typed_word or ""
vim.api.nvim_create_autocmd("TextChangedI", {
        callback = function()
                local row, col = unpack(vim.api.nvim_win_get_cursor(0))
                local line = vim.api.nvim_get_current_line()

                if col == 0 then
                        return
                end

                local prev = line:sub(col, col)
                local curr = line:sub(col + 1, col + 1)

                -- word just finished
                if prev:match("[%w_]") and not curr:match("[%w_]") then
                        local word = vim.fn.expand("<cword>")
                                highlight_word("LastCreatedWordAlt", word)
                        if word ~= "" then
                                last_typed_word = word
                        end
                end
        end,
})

-- vim.keymap.set("i", "<C-g>w", function()
--   if last_typed_word == "" then return end
--   vim.api.nvim_put({ last_typed_word }, "c", true, true)
-- end, {
--   desc = "Insert last typed word",
-- })

vim.keymap.set("i", "<C-g>q", function()
        if last_created_word == "" then
                return
        end
        vim.api.nvim_put({ last_created_word }, "c", true, true)
end, {
        desc = "Insert last created identifier",
})

_G.last_word_operator = function(type)
        if last_created_word == "" then
                return
        end

        -- apply change operator to the motion
        if type == "char" then
                vim.cmd("normal! c" .. last_created_word)
        elseif type == "line" then
                vim.cmd("normal! c" .. last_created_word)
        elseif type == "block" then
                vim.notify("Block mode not supported", vim.log.levels.WARN)
        end
end

vim.keymap.set("n", "gw", function()
        vim.o.operatorfunc = "v:lua.last_word_operator"
        return "g@"
end, { expr = true, desc = "Replace motion with remembered identifier" })
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

vim.keymap.set({ "n", "x" }, "<leader>rs", function()
        require("rip-substitute").sub()
end, { desc = " rip substitute" })

vim.keymap.set("v", "<leader>jl", function()
        -- remove newlines
        vim.cmd("'<,'>s/\\n/ /g")
        -- collapse multiple spaces into one
        vim.cmd("'<,'>s/\\s\\+/ /g")
end, { desc = "Join lines & clean spaces" })

-- vim.keymap.set("n", "yy", '"0yy', { noremap = true, silent = true })
-- Lua
-- vim.keymap.set("n", "x", require("substitute").operator, { noremap = true }) -- like yi{ then xi{
-- vim.keymap.set("n", "xl", require("substitute").line, { noremap = true }) -- after yanking line, then xl
-- vim.keymap.set("n", "X", require("substitute").eol, { noremap = true }) -- pastes then removes other stuff till eol
-- vim.keymap.set("x", "x", require("substitute").visual, { noremap = true }) -- removes the selection, pastes the yank
--
-- vim.keymap.set("n", "<leader>x", require("substitute.exchange").operator, { noremap = true })
-- vim.keymap.set("x", "<leader>x", require("substitute.exchange").visual, { noremap = true })
-- vim.keymap.set("n", "<leader>X", require("substitute.exchange").line, { noremap = true })
