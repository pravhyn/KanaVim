-- to delete multiple buffers at the same time [Buffer Deletion Menu]
local width = math.floor(vim.o.columns * 0.8)
local height = math.floor(vim.o.lines * 0.8)
local col = math.floor((vim.o.columns - width) / 2)
local row = math.floor((vim.o.lines - height) / 2)

local config = {
        title = "BufferDeletion Menu",
        title_pos = "center",
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        style = "minimal",
        border = "rounded",
}

--- returns buffers List of strings
---@return string[]
local function return_buffers_list()
        local buffersList = vim.api.nvim_list_bufs()
        local buffersListText = {}

        for i = 1, #buffersList do
                local bufferName = vim.api.nvim_buf_get_name(buffersList[i])
                local nameId = bufferName .. " -" .. buffersList[i]
                table.insert(buffersListText, nameId)
        end

        return buffersListText
end

local big_line = "----------------------------------------------------"

local function floatingBuffer()
        local bufId = vim.api.nvim_create_buf(false, true)
        local header_options = "Reload [r]"
        local buffer_list = return_buffers_list()

        -- adding options

        table.insert(buffer_list, 1, header_options)
        table.insert(buffer_list, 2, big_line)
        table.insert(buffer_list, #buffer_list + 1, big_line)

        vim.api.nvim_buf_set_lines(bufId, 0, -1, true, buffer_list)

        local winId = vim.api.nvim_open_win(bufId, true, config)

        local shadow_buffer = vim.api.nvim_buf_get_lines(bufId, 0, -1, false)
        vim.keymap.set("n", "q", function()
                vim.api.nvim_win_close(winId, false)
        end, { buffer = bufId })

        -- updating buffers Lists
        vim.keymap.set("n", "<localleader>r", function()
                buffer_list = return_buffers_list()
                vim.api.nvim_buf_set_lines(bufId, 0, -1, true, buffer_list)
        end, { buffer = bufId })

        vim.api.nvim_buf_attach(bufId, false, {
                -- Needs to improve this shitty logic for multiple deletions
                on_lines = function(string, buf, _, first, last, new_last)
                        -- Deleted detected
                        if last > new_last then







                                -- local new_notif = table.concat(notifications, ",")
                                -- vim.notify(new_notif)
                        end

                        -- vim.schedule(function()
                        --         vim.api.nvim_buf_delete(tonumber(bufferNumber), { force = false })
                        -- end)
                end,
        })
end

vim.keymap.set("n", "<leader>bdd", floatingBuffer)
