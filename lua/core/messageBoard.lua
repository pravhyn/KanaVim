local Layout = require("nui.layout")
local Popup = require("nui.popup")
local Input = require("nui.input")
local event = require("nui.utils.autocmd").event

local function notifications_to_lines()
        local history = require("snacks").notifier.get_history()
        if not history or vim.tbl_isempty(history) then
                vim.notify("No notifications in history", vim.log.levels.WARN)
                return
        end

        local lines = {}

        for i, n in ipairs(history) do
                local title = (n.title and n.title ~= "") and n.title or "Notification"
                local level = n.level or "info"
                local icon = n.icon or ""
                local time = n.added and os.date("%Y-%m-%d %H:%M:%S", math.floor(n.added)) or "unknown"

                table.insert(lines, string.rep("─", 40))
                table.insert(lines, string.format("%d. %s [%s] %s @ %s", i, icon, level:upper(), title, time))

                if n.msg then
                        for _, msg_line in ipairs(vim.split(n.msg, "\n", { plain = true })) do
                                table.insert(lines, "  " .. msg_line)
                        end
                end
        end

        table.insert(lines, string.rep("─", 80))

        if lines == nil then
                lines = { "empty" }
        end
        return lines
end

local function messages_to_buffer()
        -- Use redir to capture the real :messages output
        vim.cmd([[
    redir => g:__nvim_messages
    silent messages
    redir END
  ]])

        local output = vim.g.__nvim_messages
        vim.g.__nvim_messages = nil -- cleanup

        if not output or output == "" then
                return { "No messages found" }
        end

        local lines = {}
        table.insert(lines, "# Neovim :messages")
        table.insert(lines, "")
        table.insert(lines, string.rep("─", 80))

        for _, line in ipairs(vim.split(output, "\n", { plain = true })) do
                table.insert(lines, line)
        end

        table.insert(lines, string.rep("─", 80))

        return lines
end

local notification_panel = Popup({
        border = {
                style = "double",
                text = {
                        top = "Notifications List",
                        top_align = "center",
                },
        },
        enter = true,
})
local layout = Layout(
        {
                -- anchor = "SW",
                relative = "editor",
                position = {
                        row = "10%",
                        col = "50%",
                },
                size = {
                        height = 40,
                        width = 80,
                },
        },
        Layout.Box({
                Layout.Box(notification_panel, { size = "100%" }),
        }, { dir = "row" })
)

layout:mount()

-- close on <Esc>
notification_panel:map("n", "<Esc>", function()
        notification_panel:unmount()
end, { noremap = true })

-- local function snap(anchor, row, col, w, h)
--         layout:update({
--                 anchor = anchor,
--                 relative = "editor",
--                 position = { row = row, col = col },
--                 size = { width = w, height = h },
--         })
-- end
--
-- notification_panel:map("n", "<C-w>l", function()
--         snap("NE", "10%", "99%", 80, 40)
-- end)
--
-- notification_panel:map("n", "<C-w>;", function()
--         snap("NW", "10%", "50%", 80, 40)
-- end)
--
-- notification_panel:map("n", "<C-w>k", function()
--         snap("NE", "1%", "99%", 160, 20)
-- end)

-- shift Left Right Middle
notification_panel:map("n", "<C-w>h", function()
        layout:update({
                -- anchor = "SW",
                relative = "editor",
                position = {
                        row = "10%",
                        col = "0%",
                },
                size = {
                        height = 40,
                        width = 80,
                },
        })
end, { noremap = true })

notification_panel:map("n", "<C-w>l", function()
        layout:update({
                -- anchor = "NE",
                relative = "editor",
                position = {
                        row = "0%",
                        col = "100%",
                },
                size = {
                        height = 40,
                        width = 80,
                },
        })
end, { noremap = true })
local notifications_lines = notifications_to_lines()
notification_panel:map("n", "<C-w>;", function()
        layout:update({
                -- anchor = "SW",
                relative = "editor",
                position = {
                        row = "10%",
                        col = "50%",
                },
                size = {
                        height = 40,
                        width = 80,
                },
        })
end, { noremap = true })

notification_panel:map("n", "<C-w>k", function()
        layout:update({
                anchor = "NE",
                relative = "editor",
                position = {
                        row = "1%",
                        col = "100%",
                },
                size = {
                        height = 20,
                        width = 160,
                },
        })
end, { noremap = true })

notification_panel:map("n", "<C-w>j", function()
        layout:update({
                anchor = "NE",
                relative = "editor",
                position = {
                        row = "100%",
                        col = "1%",
                },
                size = {
                        height = 20,
                        width = 160,
                },
        })
end, { noremap = true })
vim.api.nvim_buf_set_lines(notification_panel.bufnr, 0, -1, false, notifications_lines or { "empty" })

vim.keymap.set("n", "<leader>ft", function() end, { desc = "Notification Panel" })
