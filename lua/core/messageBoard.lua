local Layout = require("nui.layout")
local Popup = require("nui.popup")
local Input = require("nui.input")
local event = require("nui.utils.autocmd").event

local function reverse_table(t)
        local reversed = {}
        for i = #t, 1, -1 do
                table.insert(reversed, t[i])
        end
        return reversed
end

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

                table.insert(lines, string.rep("─", 20))
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

        local reverserd_lines = reverse_table(lines)
        return reverserd_lines
end

local function notification_panel_open()
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

        notification_panel:map("n", "q", function()
                notification_panel:unmount()
        end, { noremap = true })

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
                        -- anchor = "NE",
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

        notification_panel:map("n", "<localleader>r", function()
                vim.api.nvim_buf_set_lines(
                        notification_panel.bufnr,
                        0,
                        -1,
                        false,
                        notifications_to_lines() or { "empty" }
                )
        end, { noremap = true })
        vim.api.nvim_buf_set_lines(notification_panel.bufnr, 0, -1, false, notifications_to_lines() or { "empty" })
end

vim.keymap.set("n", "<C-w>x", notification_panel_open, { desc = "Notification Panel" })
