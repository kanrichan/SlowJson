a = '{ "哈哈哈":222,"123":666,"234":[{123:234},{234:234}]}'

function parse(text)
    local temp = ""
    local deep = 0
    local tree = {}
    for i = 1, #text do
        current = string.sub(text, i, i)
        local state = {
            ["{"] = function()
                deep = deep + 1
                if tree[deep] == nil then
                    table.insert(tree, {})
                end
                temp = ""
            end,
            ["}"] = function()
                table.insert(tree[deep], temp)
                cur = tree[deep]
                now = {}
                for j = 1, #cur - 1, 2 do
                    key = cur[j]
                    val = cur[j + 1]
                    now[key] = val
                end
                table.remove(tree, deep)
                deep = deep - 1
                if deep == 0 then
                    return now
                end
                tree[deep][#tree[deep]] = now
                temp = ""
            end,
            ["["] = function()
                table.insert(tree[deep], temp)
                deep = deep + 1
                if tree[deep] == nil then
                    table.insert(tree, {})
                end
                temp = ""
            end,
            ["]"] = function()
                table.insert(tree[deep], temp)
                now = tree[deep]

                table.remove(tree, deep)
                deep = deep - 1
                if deep == 0 then
                    return now
                end
                tree[deep][#tree[deep]] = now
                temp = ""
            end,
            [":"] = function()
                table.insert(tree[deep], temp)
                temp = ""
            end,
            [","] = function()
                table.insert(tree[deep], temp)
                temp = ""
            end,
            ["\""] = function()
                table.insert(tree[deep], temp)
                temp = ""
            end,
            ["\\"] = function()
                -- skip
            end
        }
        if state[current] == nil then
            temp = temp .. current
            print(temp)
        else
            ret = state[current]()
            if ret ~= nil then
                return ret
            end
        end
    end
end
