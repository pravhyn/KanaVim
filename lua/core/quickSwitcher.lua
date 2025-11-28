local Layout = require("nui.layout")
local Popup = require("nui.popup")
local Input = require("nui.input")
local event = require("nui.utils.autocmd").event

local current_buffer = vim.api.nvim_buf_get_name(0)
local current_filename = vim.fn.fnamemodify(current_buffer, ":t")

local function swallow_keys_for(ms)
        local ns = vim.api.nvim_create_namespace("key_swallow")
        vim.on_key(function()
                -- eat everything
        end, ns)

        vim.defer_fn(function()
                vim.on_key(nil, ns) -- restore key handling
        end, ms)
end
local function fuzzy_match_buffers(input)
        -- Improve this for uh pure buffer name match not the path itself
        local bufs = vim.api.nvim_list_bufs()
        current_buffer = vim.api.nvim_buf_get_name(0)
        local name = input._value or ""
        local matches = {}

        for _, buf in ipairs(bufs) do
                if vim.api.nvim_buf_is_valid(buf) then
                        local raw_bufname = vim.api.nvim_buf_get_name(buf) or ""
                        local bufname = vim.fn.fnamemodify(raw_bufname, ":t") or ""

                        if bufname ~= "" and bufname:lower():match(name:lower()) then
                                table.insert(matches, { id = buf, name = bufname })
                        end
                end
        end

        return matches
end

-- 🔥 MAIN FUNCTION
local function open_buffer_switcher()
        -- everything must be local inside this
        current_buffer = vim.api.nvim_buf_get_name(0)
        current_filename = vim.fn.fnamemodify(current_buffer, ":t")

        if current_filename == "" then
                current_filename = "No fileName"
        end
        local bottom_popup = Popup({
                border = {
                        style = "double",
                        text = {
                                top = current_filename,
                                top_align = "left",
                        },
                },
                enter = false,
        })

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
                                        swallow_keys_for(120) -- tweak 80–150 ms

                                        local win = vim.api.nvim_get_current_win()
                                        vim.api.nvim_win_set_buf(win, matches[1].id)
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
