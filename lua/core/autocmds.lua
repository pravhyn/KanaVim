-- Set relative numbers only in normal mode
-- vim.api.nvim_create_autocmd("InsertLeave", {
--         callback = function()
--                 vim.opt.relativenumber = true
--         end,
-- })
--
-- vim.api.nvim_create_autocmd("InsertEnter", {
--         callback = function()
--                 vim.wo.relativenumber = false
--         end,
-- })

vim.api.nvim_create_user_command("VMessages", function()
        vim.cmd("horizontal messages")
end, {})

-- highlights yank

-- vim.api.nvim_create_autocmd("TextYankPost", {
--         callback = function()
--                 vim.highlight.on_yank({
--                         higroup = "Visual",
--                         timeout = 500,
--                 })
--         end,
-- })

vim.api.nvim_create_autocmd("FileType", {
        pattern = "python",
        callback = function()
                vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
                        focusable = false,
                        border = "rounded",
                })
        end,
})

local function augroup(name)
        return vim.api.nvim_create_augroup("my_" .. name, { clear = true })
end
-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
        group = augroup("highlight_yank"),
        callback = function()
                (vim.hl or vim.highlight).on_yank()
        end,
})

-- resize splits if window got resized
vim.api.nvim_create_autocmd({ "VimResized" }, {
        group = augroup("resize_splits"),
        callback = function()
                local current_tab = vim.fn.tabpagenr()
                vim.cmd("tabdo wincmd =")
                vim.cmd("tabnext " .. current_tab)
        end,
})

-- go to last loc when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
        group = augroup("last_loc"),
        callback = function(event)
                local exclude = { "gitcommit" }
                local buf = event.buf
                if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
                        return
                end
                vim.b[buf].lazyvim_last_loc = true
                local mark = vim.api.nvim_buf_get_mark(buf, '"')
                local lcount = vim.api.nvim_buf_line_count(buf)
                if mark[1] > 0 and mark[1] <= lcount then
                        pcall(vim.api.nvim_win_set_cursor, 0, mark)
                end
        end,
})

-- close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
        group = augroup("close_with_q"),
        pattern = {
                "PlenaryTestPopup",
                "checkhealth",
                "dbout",
                "gitsigns-blame",
                "grug-far",
                "help",
                "lspinfo",
                "neotest-output",
                "neotest-output-panel",
                "neotest-summary",
                "notify",
                "qf",
                "spectre_panel",
                "startuptime",
                "tsplayground",
        },
        callback = function(event)
                vim.bo[event.buf].buflisted = false
                vim.schedule(function()
                        vim.keymap.set("n", "q", function()
                                vim.cmd("close")
                                pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
                        end, {
                                buffer = event.buf,
                                silent = true,
                                desc = "Quit buffer",
                        })
                end)
        end,
})

-- Fix conceallevel for json files
vim.api.nvim_create_autocmd({ "FileType" }, {
        group = augroup("json_conceal"),
        pattern = { "json", "jsonc", "json5" },
        callback = function()
                vim.opt_local.conceallevel = 0
        end,
})

-- make it easier to close man-files when opened inline
vim.api.nvim_create_autocmd("FileType", {
        group = augroup("man_unlisted"),
        pattern = { "man" },
        callback = function(event)
                vim.bo[event.buf].buflisted = false
        end,
})

-- wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
        group = augroup("wrap_spell"),
        pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
        callback = function()
                vim.opt_local.wrap = true
                vim.opt_local.spell = true
        end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
        group = augroup("auto_create_dir"),
        callback = function(event)
                if event.match:match("^%w%w+:[\\/][\\/]") then
                        return
                end
                local file = vim.uv.fs_realpath(event.match) or event.match
                vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
        end,
})

vim.api.nvim_create_user_command("LspStopSelect", function()
        local bufnr = vim.api.nvim_get_current_buf()
        local clients = vim.lsp.get_clients({ bufnr = bufnr })

        if #clients == 0 then
                vim.notify("No LSP clients attached to this buffer", vim.log.levels.INFO)
                return
        end

        vim.ui.select(clients, {
                prompt = "Stop which LSP?",
                format_item = function(client)
                        return client.name
                end,
        }, function(choice)
                if not choice then
                        return
                end

                vim.lsp.stop_client(choice.id)
                vim.notify("Stopped LSP: " .. choice.name)
        end)
end, {})

