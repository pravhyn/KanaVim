-- detailed_report.lua

local function copy_lines_with_diagnostics(start_lnum, end_lnum)
        local bufnr = 0
        local out = {}

        local lines = vim.api.nvim_buf_get_lines(bufnr, start_lnum, end_lnum + 1, false)

        for i, text in ipairs(lines) do
                local lnum = start_lnum + i - 1

                local diags = vim.diagnostic.get(bufnr, { lnum = lnum })
                if #diags > 0 then
                        local msgs = {}
                        for _, d in ipairs(diags) do
                                table.insert(msgs, d.message)
                        end

                        -- append diagnostics inline
                        text = text .. "  -- " .. table.concat(msgs, " | ")
                end

                table.insert(out, text)
        end
        vim.fn.setreg("+", table.concat(out, "\n"))
end

local function copy_current_line()
        local lnum = vim.fn.line(".") - 1
        copy_lines_with_diagnostics(lnum, lnum)
end

local function copy_visual_lines()
        local start = vim.fn.line("v") - 1
        local finish = vim.fn.line(".") - 1

        if start > finish then
                start, finish = finish, start
        end

        copy_lines_with_diagnostics(start, finish)
end

vim.keymap.set({ "n", "x" }, "<leader>rl", function()
        local mode = vim.fn.mode()

        if mode == "n" then
                copy_current_line()
        elseif mode == "V" then
                copy_visual_lines()
        else
                -- ignore char-wise / block-wise on purpose
        end
end, { desc = "Copy lines + LSP diagnostics" })

-- local M = {}
--
-- -- Helper: get diagnostics for the current line
-- local function get_diagnostics_for_line()
--         local bufnr = vim.api.nvim_get_current_buf()
--         local line = vim.api.nvim_win_get_cursor(0)[1] - 1
--         local diagnostics = vim.diagnostic.get(bufnr, { lnum = line })
--         return diagnostics, line
-- end
--
-- -- Helper: safely read a few lines from another file
-- local function get_file_snippet(filepath, start_line, before, after)
--         local ok, lines = pcall(vim.fn.readfile, filepath)
--         if not ok or not lines then
--                 return "(could not read file)"
--         end
--
--         local s = math.max(1, start_line - before)
--         local e = math.min(#lines, start_line + after)
--         local snippet = {}
--         for i = s, e do
--                 table.insert(snippet, string.format("%3d | %s", i, lines[i]))
--         end
--         return table.concat(snippet, "\n")
-- end
--
-- -- Full report
-- function M.detailed_report()
--         local diagnostics, line = get_diagnostics_for_line()
--         if not diagnostics or vim.tbl_isempty(diagnostics) then
--                 print("✅ No diagnostics on this line.")
--                 return
--         end
--
--         print("📋 Diagnostics on line " .. (line + 1) .. ":")
--         for _, diag in ipairs(diagnostics) do
--                 local msg = diag.message:gsub("\n", " ")
--                 print("  → " .. msg)
--         end
--
--         local params = vim.lsp.util.make_position_params()
--         vim.lsp.buf_request_all(0, "textDocument/definition", params, function(results)
--                 local snippets = {}
--                 for _, res in pairs(results or {}) do
--                         if res.result then
--                                 for _, loc in ipairs(res.result) do
--                                         local uri = loc.uri or loc.targetUri
--                                         local range = loc.range or loc.targetSelectionRange
--                                         if uri and range then
--                                                 local filename = vim.uri_to_fname(uri)
--                                                 local start_line = range.start.line + 1
--                                                 local snippet = get_file_snippet(filename, start_line, 2, 3)
--                                                 table.insert(
--                                                         snippets,
--                                                         string.format(
--                                                                 "📂 %s (around line %d):\n%s",
--                                                                 filename,
--                                                                 start_line,
--                                                                 snippet
--                                                         )
--                                                 )
--                                         end
--                                 end
--                         end
--                 end
--
--                 if vim.tbl_isempty(snippets) then
--                         print("🔍 No related definitions found.")
--                 else
--                         print("🔗 Related code snippets:")
--                         for _, s in ipairs(snippets) do
--                                 print("\n" .. s .. "\n")
--                         end
--                 end
--         end)
-- end
--
-- -- Simple report
-- function M.report_line()
--         local bufnr = vim.api.nvim_get_current_buf()
--         local diagnostics, line = get_diagnostics_for_line()
--         local text = vim.api.nvim_buf_get_lines(bufnr, line, line + 1, false)[1] or ""
--
--         print(string.format("%d: %s", line + 1, text))
--         if not diagnostics or vim.tbl_isempty(diagnostics) then
--                 print("✅ No diagnostics for this line.")
--                 return
--         end
--
--         for _, diag in ipairs(diagnostics) do
--                 local msg = diag.message:gsub("\n", " ")
--                 print("  ⚠️ " .. msg)
--         end
-- end
--
-- -- Keymaps
-- vim.keymap.set("n", "<leader>rp", function()
--         M.detailed_report()
-- end, { desc = "Show detailed report for current line" })
--
-- vim.keymap.set("n", "<leader>rl", function()
--         M.report_line()
-- end, { desc = "Quick report: show current line + diagnostic" })
--
-- return M
