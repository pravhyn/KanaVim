local function to_snake_case(str)
        -- camelCase / PascalCase → snake_case
        local s = str:gsub("(%l)(%u)", "%1_%2"):gsub("(%u)(%u%l)", "%1_%2"):lower()
        return s
end

local function to_camel_case(str)
        -- snake_case → camelCase
        local s = str:lower():gsub("_(%l)", function(c)
                return c:upper()
        end)
        return s
end

local function smart_case_rename()
        local word = vim.fn.expand("<cword>")
        if not word or word == "" then
                return
        end

        local ft = vim.bo.filetype
        local new_word = word

        if ft == "python" then
                -- convert camelCase → snake_case
                new_word = to_snake_case(word)
        elseif ft == "javascript" or ft == "javascriptreact" or ft == "typescript" or ft == "typescriptreact" then
                -- convert snake_case → camelCase
                new_word = to_camel_case(word)
        else
                -- unsupported filetype
                return
        end

        if new_word == word then
                return
        end

        -- replace only the word under cursor
        vim.cmd.normal({
                args = { string.format("ciw%s", new_word) },
                bang = true,
        })
end

vim.keymap.set("n", "<leader>rc", smart_case_rename, {
        desc = "Rename variable based on filetype (snake/camel)",
})
