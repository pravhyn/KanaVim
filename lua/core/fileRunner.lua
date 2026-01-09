vim.keymap.set("n", "<leader>run", function()
        local file = vim.api.nvim_buf_get_name(0)

        if file == "" then
                require("snacks").notify("No file to run", {
                        level = vim.log.levels.WARN,
                })
                return
        end

        local ext = vim.fn.fnamemodify(file, ":e")

        -- Decide runner
        local cmd
        local title

        if ext == "py" then
                cmd = { "python", file }
                title = "Python Output"
        elseif ext == "js" then
                cmd = { "node", file }
                title = "Node.js Output"
        else
                require("snacks").notify("Unsupported file type: " .. ext, "warn")
                return
        end

        local start = vim.uv.hrtime()
        local finished = false
        local job

        job = vim.system(cmd, { text = true }, function(res)
                if finished then
                        return
                end
                finished = true

                local finish = vim.uv.hrtime()
                local duration = (finish - start) / 1e9

                local output = res.stdout ~= "" and res.stdout or res.stderr
                local msg = string.format("%s\n\n⏱ Took %.3f seconds", output, duration)

                require("snacks").notify(msg, {
                        title = title,
                })
        end)

        vim.defer_fn(function()
                if job and job.pid and not finished then
                        finished = true
                        job:kill(15)
                        require("snacks").notify("⛔ Program killed (took > 10s)", {
                                level = vim.log.levels.WARN,
                        })
                end
        end, 10000)
end, { desc = "Run current file (Python / JS) and notify output" })
