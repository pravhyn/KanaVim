local Input = require("nui.input")
local Layout = require("nui.layout")
local Popup = require("nui.popup")

-- Function: Search using Everything CLI (es.exe)
-- Input: query (string)
-- Output: results as table (each line = one path)
-- TODO: return edited path based on language of the buffer
-- TODO: return dir parent of the file instead of the file's path
-- FIX: File explorer option doesn't work

local function everything(picker)
        local origin_win = vim.api.nvim_get_current_win()
        local result_box = Popup({
                enter = true,
                border = {
                        style = "single",
                        text = {
                                -- top = "Lol",
                                -- top_align = "left",
                        },
                },
        })

        --- opens the file as buffer
        ---@param path string accepts absolute path strings, and opens the file as buffer
        local function open_path(path)
                if not path or path == "" then
                        return
                end

                -- strip Windows CR if still present
                path = path:gsub("\r", "")

                -- normalize slashes (optional but nice)
                path = vim.fn.fnamemodify(path, ":p")
                if origin_win and vim.api.nvim_win_is_valid(origin_win) then
                        vim.api.nvim_set_current_win(origin_win)
                end

                vim.cmd("edit " .. vim.fn.fnameescape(path))
        end

        --- returns absolute path as string
        ---@param path string accepts absolute path strings, and opens the file as buffer
        local function yank_path(path)
                if not path or path == "" then
                        return
                end

                path = path:gsub("\r", "")
                path = vim.fn.fnamemodify(path, ":p")
                vim.fn.setreg('"', path)

                -- vim.notify(path, vim.log.levels.INFO, {
                --         title = "Selected path",
                -- }
        end

        --- opens the file in file explorer
        ---@param path string accepts absolute path strings, and opens the file in File explorer
        local function open_in_file_explorer(path)
                if not path or path == "" then
                        return
                end

                -- sanitize
                path = path:gsub("\r", "")
                path = vim.fn.fnamemodify(path, ":p")

                local target = path

                -- if it's a file, open parent directory
                if vim.fn.filereadable(path) == 1 then
                        target = vim.fn.fnamemodify(path, ":h")
                end

                -- Windows
                if vim.fn.has("win32") == 1 then
                        vim.fn.jobstart({ "explorer", target }, { detach = true })

                -- macOS
                elseif vim.fn.has("mac") == 1 then
                        vim.fn.jobstart({ "open", target }, { detach = true })

                -- Linux / BSD
                else
                        vim.fn.jobstart({ "xdg-open", target }, { detach = true })
                end
        end

        local function debounce(fn, delay)
                local timer = vim.loop.new_timer()
                return function(...)
                        local args = { ... }
                        timer:stop()
                        timer:start(delay, 0, function()
                                vim.schedule(function()
                                        fn(unpack(args))
                                end)
                        end)
                end
        end

        local function search_everything(query)
                if not query or query == "" then
                        vim.notify("No query provided", vim.log.levels.ERROR)
                        return {}
                end

                -- Path to ES CLI (change if needed)
                local es_path = "es" -- If es.exe is in PATH
                -- local es_path = "C:\\Tools\\Everything\\es.exe"

                -- Build CLI command
                local cmd = {
                        "es",
                        -- "-name",
                        query,
                        -- "-full-path", -- so we get absolute paths
                        -- "-sort",
                        -- "name", -- sorting (optional)
                }

                -- Run command and capture output
                local output = vim.fn.systemlist(cmd)

                -- Handle errors
                if vim.v.shell_error ~= 0 then
                        vim.notify("Everything search failed", vim.log.levels.ERROR)
                        return {}
                end

                for i, line in ipairs(output) do
                        output[i] = line:gsub("\r", "")
                end

                return output
        end

        local function search_everything_fzf(query)
                if not query or query == "" then
                        return {}
                end

                local cmd = table.concat({
                        "es",
                        vim.fn.shellescape(query),
                        "| fzf --filter",
                        vim.fn.shellescape(query),
                }, " ")

                local results = vim.fn.systemlist(cmd)

                for i, line in ipairs(results) do
                        results[i] = line:gsub("\r", "")
                end

                return results
        end

        local results = {}

        local update_results = debounce(function(value)
                results = search_everything_fzf(value)

                vim.schedule(function()
                        -- FIX: result_box.bufnr gets destroyed on submit, and below code gives the error
                        if vim.api.nvim_buf_is_valid(result_box.bufnr) then
                                vim.api.nvim_buf_set_lines(result_box.bufnr, 0, -1, false, results)
                        end
                end)
        end, 300)
        local input_box = Input({

                size = {
                        width = 20,
                },
                border = {
                        style = "single",
                        text = {
                                top = "everything",
                                top_align = "center",
                        },
                },
        }, {
                prompt = "> ",
                -- default_value = "Hello",

                on_change = function(value)
                        update_results(value)
                end,

                on_submit = function(value)
                        if picker == "buffer" then
                                open_path(results[1])
                        elseif picker == "yank" then
                                yank_path(results[1])
                        elseif picker == "file" then
                                open_in_file_explorer(results[1])
                        end
                end,
                on_close = function()
                        print("Input Closed")
                end,
        })

        local layout = Layout(
                {
                        relative = "editor",
                        position = "50%",
                        size = {
                                width = 100,
                                height = 30,
                        },
                },
                Layout.Box({
                        Layout.Box(input_box, { size = "10%" }),
                        Layout.Box(result_box, { size = "90%" }),
                }, { dir = "col" })
        )

        layout:mount()

        -- close on <Esc>
        input_box:map("n", "<Esc>", function()
                input_box:unmount()
        end, { noremap = true })
end
vim.keymap.set("n", "<leader>fe", function()
        everything("buffer")
end, { desc = "search everything" })

vim.api.nvim_create_user_command("Yankpath", function()
        everything("yank")
end, { desc = "Yanks the path" })

vim.api.nvim_create_user_command("OpenInFileExplorer", function()
        everything("file")
end, { desc = "Open FileExplorer" })
