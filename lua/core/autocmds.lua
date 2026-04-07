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


-- Store python path
local stored_python_path = nil

-- Function to get current python path
local function get_python_path()
  local handle = io.popen("where python")
  if not handle then return nil end
  local result = handle:read("*l")
  handle:close()
  return result
end

-- Capture python path when LSP attaches
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.name == "pyright" then
      stored_python_path = get_python_path()
      print("Stored Python: " .. (stored_python_path or "nil"))
    end
  end,
})

-- Command to check & restart LSP if needed
vim.api.nvim_create_user_command("CheckPythonEnv", function()
  local current = get_python_path()

  if not current then
    print("Could not detect python path")
    return
  end

  print("Current: " .. current)
  print("Stored: " .. (stored_python_path or "nil"))

  if stored_python_path ~= current then
    print("Python changed! Restarting LSP...")

    -- stop all python LSP clients
    for _, client in pairs(vim.lsp.get_active_clients()) do
      if client.name == "pyright" then
        client.stop()
      end
    end

    -- restart LSP
    vim.cmd("LspStart pyright")

    stored_python_path = current
  else
    print("Python environment unchanged.")
  end
end, {})

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

local function open_term(shell, cwd, cmd)
        vim.cmd("botright split")
        vim.cmd("enew") -- new empty buffer
        vim.cmd("resize 15")

        vim.fn.termopen(shell, {
                cwd = cwd,
                on_exit = function(_, code)
                        vim.notify(("Process exited (%s)"):format(code), vim.log.levels.INFO)
                end,
        })

        -- send command after terminal starts
        vim.defer_fn(function()
                vim.fn.chansend(vim.b.terminal_job_id, cmd .. "\r")
        end, 100)
end
local function run()
        local config = dofile(vim.fn.getcwd() .. "/runbook.lua")

        if not config then
                vim.notify("no config exists")
                return
        end

        local shell = config.shell or "pwsh"
        local wait = (config.wait or 10) * 1000

        local i = 1
        local function next_step()
                local step = config.steps[i]
                if not step then
                        return
                end

                open_term(shell, step.cwd, step.cmd)
                i = i + 1

                if config.steps[i] then
                        vim.defer_fn(next_step, wait)
                end
        end

        next_step()
end

vim.api.nvim_create_user_command("RunConfig", function()
        run()
end, { desc = "Run Config" })

vim.api.nvim_create_user_command("RunDesc", function()
        local query = vim.fn.input("Run desc: ")
        if query == "" then
                return
        end

        query = query:lower()
        local results = {}

        -- -----------------------
        -- Keymaps
        -- -----------------------
        local modes = { "n", "i", "v", "x", "s", "o", "t", "c" }

        for _, mode in ipairs(modes) do
                for _, map in ipairs(vim.api.nvim_get_keymap(mode)) do
                        if map.desc and map.desc:lower():find(query, 1, true) then
                                table.insert(results, {
                                        kind = "keymap",
                                        mode = mode,
                                        lhs = map.lhs,
                                        rhs = map.rhs,
                                        desc = map.desc,
                                })
                        end
                end
        end

        -- -----------------------
        -- Autocmds
        -- -----------------------
        for _, ac in ipairs(vim.api.nvim_get_autocmds({})) do
                if ac.desc and ac.desc:lower():find(query, 1, true) then
                        table.insert(results, {
                                kind = "autocmd",
                                event = ac.event,
                                group = ac.group_name,
                                desc = ac.desc,
                        })
                end
        end

        if vim.tbl_isempty(results) then
                vim.notify("No matches found", vim.log.levels.INFO)
                return
        end

        vim.ui.select(results, {
                prompt = "Activate:",
                format_item = function(item)
                        if item.kind == "keymap" then
                                return string.format("[keymap %s] %s → %s", item.mode, item.lhs, item.desc)
                        else
                                return string.format("[autocmd %s] %s", table.concat(item.event, ","), item.desc)
                        end
                end,
        }, function(choice)
                if not choice then
                        return
                end

                -- -----------------------
                -- Execute selection
                -- -----------------------
                if choice.kind == "keymap" then
                        -- Replay the keymap
                        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(choice.lhs, true, false, true), "n", false)
                elseif choice.kind == "autocmd" then
                        -- Best-effort: trigger event(s)
                        for _, ev in ipairs(choice.event) do
                                vim.cmd("doautocmd " .. ev)
                        end
                        vim.notify(
                                "Triggered autocmd event(s): " .. table.concat(choice.event, ", "),
                                vim.log.levels.INFO
                        )
                end
        end)
end, {
        desc = "Search & activate keymaps or autocmds by description",
})

vim.api.nvim_create_user_command("SearchDesc", function()
        local query = vim.fn.input("Search desc: ")
        if query == "" then
                return
        end

        query = query:lower()
        local items = {}

        -- -----------------------
        -- Keymaps
        -- -----------------------
        local modes = { "n", "i", "v", "x", "s", "o", "t", "c" }

        for _, mode in ipairs(modes) do
                for _, map in ipairs(vim.api.nvim_get_keymap(mode)) do
                        if map.desc and map.desc:lower():find(query, 1, true) then
                                table.insert(items, {
                                        filename = "[keymap]",
                                        lnum = 1,
                                        col = 1,
                                        text = string.format("[%s] %s → %s", mode, map.lhs, map.desc),
                                })
                        end
                end
        end

        -- -----------------------
        -- Autocmds
        -- -----------------------
        for _, ac in ipairs(vim.api.nvim_get_autocmds({})) do
                if ac.desc and ac.desc:lower():find(query, 1, true) then
                        local group = ac.group_name or "no-group"
                        local event = table.concat(ac.event, ",")

                        table.insert(items, {
                                filename = "[autocmd]",
                                lnum = 1,
                                col = 1,
                                text = string.format("[%s | %s] %s", event, group, ac.desc),
                        })
                end
        end

        if vim.tbl_isempty(items) then
                vim.notify("No matches found", vim.log.levels.INFO)
                return
        end

        vim.fn.setqflist({}, " ", {
                title = "SearchDesc: " .. query,
                items = items,
        })
        vim.cmd("copen")
end, {
        desc = "Search keymap & autocmd descriptions",
})

vim.api.nvim_create_user_command("RgConfig", function()
        local config = vim.fn.stdpath("config")

        require("snacks").picker.grep({
                cwd = config,
                prompt = "RgConfig ❯ ",
        })
end, {})

local function get_git_root(path)
        local dir = vim.fn.fnamemodify(path, ":h")

        local res = vim.system({ "git", "-C", dir, "rev-parse", "--show-toplevel" }, { text = true }):wait()

        if res.code == 0 and res.stdout ~= "" then
                return res.stdout:gsub("\n", "")
        end

        return nil
end

vim.api.nvim_create_user_command("RgSmart", function()
        local snacks = require("snacks")
        local cwd = vim.fn.getcwd()
        local file = vim.api.nvim_buf_get_name(0)

        if file == "" then
                vim.notify("No file in current buffer")
                return
        end

        local file_dir = vim.fn.fnamemodify(file, ":h")
        local git_root = get_git_root(file)

        local choices = {
                { label = "CWD", path = cwd },
                { label = "File project root", path = git_root },
                { label = "File parent dir", path = file_dir },
        }

        -- filter invalid ones
        local items = {}
        for _, c in ipairs(choices) do
                if c.path and c.path ~= "" then
                        table.insert(items, c)
                end
        end

        vim.ui.select(items, {
                prompt = "Rg scope:",
                format_item = function(item)
                        return string.format("%-20s %s", item.label, item.path)
                end,
        }, function(choice)
                if not choice then
                        return
                end

                snacks.picker.grep({
                        cwd = choice.path,
                        prompt = "RgSmart (" .. choice.label .. ") ❯ ",
                })
        end)
end, {})
