local function grep_python_module(mod)
        local cmd = string.format(
                [[python -c "import %s; import sys; 
try:
 print(%s.__path__[0])
except:
 print(%s.__file__)"]],
                mod,
                mod,
                mod
        )

        local path = vim.fn.system(cmd):gsub("%s+$", "")

        if path == "" then
                vim.notify("Module not found: " .. mod, vim.log.levels.ERROR)
                return
        end

        vim.notify(path)

        require("snacks").picker.grep({
                dirs = { path },
                title = "Grep module: " .. mod,
        })
end

local function grep_module_under_cursor()
        local mod = vim.fn.expand("<cword>")
        grep_python_module(mod)
end

vim.keymap.set("n", "<leader>gm", grep_module_under_cursor, {
        desc = "Grep Python module under cursor",
})
