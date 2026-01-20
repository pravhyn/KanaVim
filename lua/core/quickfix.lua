local function get_visual_lines()
        local bufnr = 0

        local start_pos = vim.fn.getpos("'<")
        local end_pos = vim.fn.getpos("'>")

        local start_line = start_pos[2] - 1
        local end_line = end_pos[2]

        return vim.api.nvim_buf_get_lines(bufnr, start_line, end_line, false)
end

local function logs_to_quickfix()
        local lines = get_visual_lines()
        local items = {}

        for _, line in ipairs(lines) do
                -- file.lua:123
                local file, lnum = line:match("([^%s:]+%.lua):(%d+)")
                if file and lnum then
                        table.insert(items, {
                                filename = file,
                                lnum = tonumber(lnum),
                                text = line,
                        })
                end
        end

        if vim.tbl_isempty(items) then
                vim.notify("No file:line matches found", vim.log.levels.WARN)
                return
        end

        -- Replace quickfix list
        vim.fn.setqflist({}, " ", {
                title = "Parsed Logs",
                items = items,
        })

        vim.cmd("copen")
end

vim.keymap.set("v", "<leader>qf", logs_to_quickfix, {
        desc = "Parse logs → quickfix",
})
