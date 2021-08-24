a = '{"哈哈哈":222,"123":666,"234":[{123:234},{234:234}]}'

function load(s)
    local temp = ""
    local deep = 0
    local tree = {}
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
    for i = 1, #s do
        current = string.sub(s, i, i)
        if state[current] ~= nil then
            ret = state[current]()
            if ret ~= nil then
                return ret
            end
        else
            temp = temp .. current
        end
    end
end

function dump(obj)
    local deep = 0
    local index = 0
    local times = {}
    local cur = obj
    local ret = ""
    ::label::
    do
        for k, v in pairs(cur) do
            if type(v) == "string" then
                ret = ret .. "\"" .. k .. "\"" .. ": " .. "\"" .. v .. "\""
            elseif type(v) == "number" then
                ret = ret .. "\"" .. k .. "\"" .. ": " .. v
            elseif type(v) == "table" then
                
            end
            goto label
        end
    end
end
