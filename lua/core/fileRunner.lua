-- Meant for running whole File
vim.keymap.set("n", "<leader>run", function()
        local file = vim.api.nvim_buf_get_name(0)

        if file == "" then
                require("snacks").notify("No file to run", "warn")
                return
        end

        -- high-precision start time
        local start = vim.uv.hrtime()

        vim.system({ "python", file }, { text = true }, function(res)
                -- calculate duration
                local finish = vim.uv.hrtime()
                local duration = (finish - start) / 1e9 -- convert ns → seconds

                -- choose output (stdout or stderr)
                local output = res.stdout ~= "" and res.stdout or res.stderr

                -- final message with timing included
                local msg = string.format("%s\n\n⏱ Took %.3f seconds", output, duration)

                require("snacks").notify(msg, {
                        title = "Python Output",
                })
        end)
end, { desc = "Run Python file and notify output" })
