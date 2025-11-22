local Layout = require("nui.layout")
local Popup = require("nui.popup")
local Input = require("nui.input")
local event = require("nui.utils.autocmd").event

local function fuzzy_match_buffers(input)
        -- Improve this for uh pure buffer name match not the path itself
        local bufs = vim.api.nvim_list_bufs()
        local name = input._value or ""
        local matches = {}

        for _, buf in ipairs(bufs) do
                if vim.api.nvim_buf_is_loaded(buf) then
                        local bufname = vim.api.nvim_buf_get_name(buf) or ""
                        if bufname ~= "" and bufname:lower():match(name:lower()) then
                                table.insert(matches, { id = buf, name = bufname })
                        end
                end
        end

        return matches
end

-- 🔥 MAIN FUNCTION
local function open_buffer_switcher()
        -- everything must be local inside this function
        local bottom_popup = Popup({ border = "double", enter = false })

        local input -- forward declare so on_change can reference it

        input = Input({
                position = "50%",
                size = { width = 20 },
                border = {
                        style = "single",
                        text = { top = "[Buffer search]", top_align = "center" },
                },
        }, {
                prompt = "> ",
                default_value = "",
                on_submit = function(value)
                        input:unmount()
                end,

                on_change = function(value)
                        local matches = fuzzy_match_buffers({ _value = value })

                        -- update bottom list
                        local lines = {}
                        for _, m in ipairs(matches) do
                                table.insert(lines, m.name)
                        end
                        if #lines == 0 then
                                lines = { "No matches…" }
                        end

                        vim.schedule(function()
                                vim.api.nvim_buf_set_lines(bottom_popup.bufnr, 0, -1, false, lines)
                        end)

                        -- auto-jump to unique match
                        if #matches == 1 then
                                vim.schedule(function()
                                        input:unmount()
                                        vim.api.nvim_set_current_buf(matches[1].id)
                                end)
                        end
                end,
        })

        local layout = Layout(
                {
                        relative = "editor",
                        position = "50%",
                        size = { width = 80, height = 20 },
                },
                Layout.Box({
                        Layout.Box(input, { size = "10%" }),
                        Layout.Box(bottom_popup, { size = "90%" }),
                }, { dir = "col" })
        )

        layout:mount()

        -- close on <Esc>
        input:map("n", "<Esc>", function()
                input:unmount()
        end, { noremap = true })
end

-- 🔥 KEYMAP
vim.keymap.set("n", "<leader>;", open_buffer_switcher, { desc = "Live buffer switcher" })
