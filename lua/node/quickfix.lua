local function open_url(url)
        local cmd
        if vim.fn.has("win32") == 1 then
                cmd = { "cmd", "/c", "start", url }
        elseif vim.fn.has("unix") == 1 then
                cmd = { "xdg-open", url }
        elseif vim.fn.has("mac") == 1 then
                cmd = { "open", url }
        end
        if cmd then
                vim.fn.jobstart(cmd, { detach = true })
        end
end

local function run_and_parse(cmd)
        local output = vim.fn.systemlist(cmd .. " 2>&1")
        local qf = {}

        for _, line in ipairs(output) do
                -- Basic regex: file:line:col: message
                local file, lnum, col, msg = line:match("([^:]+):(%d+):(%d+):%s*(.+)")
                if file and lnum and col and msg then
                        table.insert(qf, {
                                filename = file,
                                lnum = tonumber(lnum),
                                col = tonumber(col),
                                text = msg,
                        })
                end
        end

        if #qf > 0 then
                vim.fn.setqflist(qf, "r")
                vim.cmd("copen")
                vim.notify("Errors found. Quickfix list populated.", vim.log.levels.ERROR)
        else
                vim.notify("Command succeeded: " .. cmd, vim.log.levels.INFO)
                -- Open the reload.extensions URL
                -- vim.fn.jobstart(
                --         { "curl", "-s", "http://reload.extensions" }
                --         -- ,{ detach = true }
                -- )

                vim.fn.jobstart({
                        "cmd.exe",
                        "/c",
                        "start",
                        "",
                        "http://reload.extensions",
                }, { detach = true })
        end

        vim.print(table.concat(output, "\n"))
end

-- E5108: Error executing lua: Vim:E475: Invalid value for argument cmd: 'start' is not executable
-- stack traceback:
-- 	[C]: in function 'jobstart'
-- 	C:/Users/prave/AppData/Local/nvim/lua/node/quickfix.lua:25: in function 'run_and_parse'
-- 	C:/Users/prave/AppData/Local/nvim/lua/node/quickfix.lua:30: in function <C:/Users/prave/AppData/Local/nvim/lua/node/quickfix.lua:29
vim.keymap.set("n", "<leader>rr", function()
        run_and_parse("npm run build")
end, { desc = "Run build and parse errors" })
