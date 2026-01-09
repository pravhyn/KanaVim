local function run_js_scratch(buf)
        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        local source = table.concat(lines, "\n")

        local output = {}
        local errors = {}

        local job_id = vim.fn.jobstart({ "node" }, {
                stdin = "pipe",
                stdout_buffered = true,
                stderr_buffered = true,

                on_stdout = function(_, data)
                        if data then
                                vim.list_extend(output, data)
                        end
                end,

                on_stderr = function(_, data)
                        if data then
                                vim.list_extend(errors, data)
                        end
                end,

                on_exit = function(_, code)
                        if code == 0 then
                                vim.notify(
                                        table.concat(output, "\n"),
                                        vim.log.levels.INFO,
                                        { title = "󰎙 Node.js Scratch" }
                                )
                        else
                                vim.notify(
                                        table.concat(errors, "\n"),
                                        vim.log.levels.ERROR,
                                        { title = "󰎙 Node.js Error" }
                                )
                        end
                end,
        })

        -- send buffer to node
        vim.fn.chansend(job_id, source)
        vim.fn.chanclose(job_id, "stdin")
end

-- local function run_python_scratch(buf)
--         local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
--         local source = table.concat(lines, "\n")
--
--         local output = {}
--         local errors = {}
--
--         local job_id = vim.fn.jobstart({ "python" }, {
--                 stdin = "pipe",
--                 stdout_buffered = true,
--                 stderr_buffered = true,
--
--                 on_stdout = function(_, data)
--                         if data then
--                                 vim.list_extend(output, data)
--                         end
--                 end,
--
--                 on_stderr = function(_, data)
--                         if data then
--                                 vim.list_extend(errors, data)
--                         end
--                 end,
--
--                 on_exit = function(_, code)
--                         if code == 0 then
--                                 vim.notify(
--                                         table.concat(output, "\n"),
--                                         vim.log.levels.INFO,
--                                         { title = " Python Scratch" }
--                                 )
--                         else
--                                 vim.notify(
--                                         table.concat(errors, "\n"),
--                                         vim.log.levels.ERROR,
--                                         { title = " Python Error" }
--                                 )
--                         end
--                 end,
--         })
--
--         -- send buffer to python
--         vim.fn.chansend(job_id, source)
--         vim.fn.chanclose(job_id, "stdin")
-- end

local function run_python_scratch(buf)
        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        local source = table.concat(lines, "\n")

        local output = {}
        local errors = {}

        local start_time = vim.loop.hrtime()
        local timeout_ms = 10000
        local timed_out = false
        local job_id

        job_id = vim.fn.jobstart({ "python", "-u" }, {
                stdin = "pipe",
                stdout_buffered = true,
                stderr_buffered = true,

                on_stdout = function(_, data)
                        if data then
                                vim.list_extend(output, data)
                        end
                end,

                on_stderr = function(_, data)
                        if data then
                                vim.list_extend(errors, data)
                        end
                end,

                on_exit = function(_, code)
                        local elapsed = (vim.loop.hrtime() - start_time) / 1e9

                        if timed_out then
                                return
                        end

                        if code == 0 then
                                vim.notify(
                                        string.format("[%.2fs]\n%s", elapsed, table.concat(output, "\n")),
                                        vim.log.levels.INFO,
                                        { title = " Python Scratch" }
                                )
                        else
                                vim.notify(
                                        string.format("[%.2fs]\n%s", elapsed, table.concat(errors, "\n")),
                                        vim.log.levels.ERROR,
                                        { title = " Python Error" }
                                )
                        end
                end,
        })

        -- send buffer to python
        vim.fn.chansend(job_id, source)
        vim.fn.chanclose(job_id, "stdin")

        -- ⏰ timeout watcher
        vim.defer_fn(function()
                if vim.fn.jobwait({ job_id }, 0)[1] == -1 then
                        timed_out = true
                        vim.fn.jobstop(job_id)

                        local elapsed = (vim.loop.hrtime() - start_time) / 1e9

                        vim.notify(
                                string.format("Killed after %.2fs (timeout)", elapsed),
                                vim.log.levels.WARN,
                                { title = " Python Timeout" }
                        )
                end
        end, timeout_ms)
end

return {
        "folke/snacks.nvim",
        ---@type snacks.Config
        opts = {
                notifier = { enabled = true },
                image = { enabled = true },
                bigfile = { enabled = true },
                explorer = { enabled = true },
                indent = { enabled = true },
                input = { enabled = true },
                quickfile = { enabled = true },
                statuscolumn = { enabled = true },
                lazygit = { enabled = true },

                words = { enabled = true },
                rename = { enabled = true },
                zen = { enabled = true },
                scratch = {
                        enabled = true,

                        win_by_ft = {
                                javascript = {
                                        keys = {
                                                ["run"] = {
                                                        "<cr>",
                                                        function(self)
                                                                run_js_scratch(self.buf)
                                                        end,
                                                        desc = "Run JS scratch with node (jobstart)",
                                                        mode = { "n", "x" },
                                                },
                                        },
                                },
                                python = {

                                        keys = {
                                                ["run"] = {
                                                        "<cr>",
                                                        function(self)
                                                                run_python_scratch(self.buf)
                                                        end,
                                                        desc = "Run py with (jobstart)",
                                                        mode = { "n", "x" },
                                                },
                                        },
                                },
                        },
                },
                dashboard = {
                        enabled = true,
                        sections = {

                                { section = "header" },

                                {
                                        section = "projects",
                                        limit = 5,
                                        cwd = false,
                                },
                                {
                                        section = "recent_files",
                                        limit = 8,
                                },
                                {
                                        section = "session",
                                },
                                {
                                        section = "keys",
                                        gap = 1,
                                        padding = 1,
                                },
                        },
                },
                animate = {
                        enabled = false,
                        -- -@type snacks.animate.Duration|number,
                        duration = 20, -- ms per step
                        easing = "linear",
                        fps = 60, -- frames per second. Global setting for all animations
                },

                picker = {
                        enabled = true,
                },

                -- trouble = {
                --         enabled = true,
                -- },
        },

        keys = {
                {
                        "<leader>.",
                        function()
                                Snacks.scratch()
                        end,
                        desc = "Toggle Scratch Buffer",
                },
                {
                        "<leader>S",
                        function()
                                Snacks.scratch.select()
                        end,
                        desc = "Select Scratch Buffer",
                },
        },
}
