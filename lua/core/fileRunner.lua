vim.keymap.set("n", "<leader>run", function()
        local file = vim.api.nvim_buf_get_name(0)

        if file == "" then
                require("snacks").notify("No file to run", "warn")
                return
        end

        local start = vim.uv.hrtime()
        local finished = false -- ✅ track completion
        local job

        job = vim.system({ "python", file }, { text = true }, function(res)
                if finished then
                        return
                end
                finished = true

                local finish = vim.uv.hrtime()
                local duration = (finish - start) / 1e9

                local output = res.stdout ~= "" and res.stdout or res.stderr
                local msg = string.format("%s\n\n⏱ Took %.3f seconds", output, duration)

                require("snacks").notify(msg, {
                        title = "Python Output",
                })
        end)

        vim.defer_fn(function()
                if job and job.pid and not finished then
                        finished = true
                        job:kill(15)
                        require("snacks").notify("⛔ Python program killed (took > 10s)", "warn")
                end
        end, 10000)
end, { desc = "Run Python file and notify output" })
