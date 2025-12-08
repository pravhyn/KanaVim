---@class Buf
Buf = Buf or {}

-- buffer name only (no path, no extension)
function Buf.name(buf)
        buf = buf or 0
        local full = vim.api.nvim_buf_get_name(buf)
        if full == "" then
                return ""
        end
        return vim.fn.fnamemodify(full, ":t:r")
end

--- use for checking fileTypes
---@param buf? integer -- Optional Buf no (0 = current Buffer)
---@return string --- ex "python", "lua"
function Buf.ft(buf)
        buf = buf or 0
        return vim.bo[buf].filetype or ""
end
function Buf.filename(buf)
        buf = buf or 0
        local full = vim.api.nvim_buf_get_name(buf)
        return full ~= "" and vim.fn.fnamemodify(full, ":t") or ""
end
