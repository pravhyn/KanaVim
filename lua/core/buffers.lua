-- to delete multiple buffers at the same time [Buffer Deletion Menu]
local function floatingBuffer(BuffersList)
        local bufId = vim.api.nvim_create_buf(false, true)

        local fixedLines = { "BufferDeletion" }
        vim.api.nvim_buf_set_lines(bufId, 0, -1, true, BuffersList)

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

        local winId = vim.api.nvim_open_win(bufId, true, config)

        vim.keymap.set("n", "q", function()
                vim.api.nvim_win_close(winId, false)
        end, { buffer = bufId })
        vim.api.nvim_buf_attach(bufId, false, {
                -- Needs to improve this shitty logic for multiple deletions
                on_lines = function(_, _, _, firstline, lastline)
                        for i = firstline, lastline - 1 do
                                local bufferItem = BuffersList[i + 1]
                                table.remove(BuffersList, i)

                                local bufferNumber = bufferItem:match("-(%d+)")
                                -- print(i)
                                -- print(bufferItem)
                                -- print(bufferNumber)

                                vim.schedule(function()
                                        vim.api.nvim_buf_delete(tonumber(bufferNumber), { force = false })
                                end)
                        end
                end,
        })
end

local function deleteBuffer()
        local buffersList = vim.api.nvim_list_bufs()
        local buffersListText = {}

        for i = 1, #buffersList do
                local bufferName = vim.api.nvim_buf_get_name(buffersList[i])
                local nameId = bufferName .. " -" .. buffersList[i]
                table.insert(buffersListText, nameId)
        end

        -- local preparedText = table.concat(buffersListText, "\n")

        floatingBuffer(buffersListText)
end

vim.keymap.set("n", "<leader>bdd", deleteBuffer)
