function raise(index, text) 
    print("[ERROR][SlowJson]" .. index .. text)
end

function loads(s)
    local temp = ""
    local deep = 0
    local tree = {}
    local array = {}
    local skip = false
    local isstr = 0

    local function tovalue(isstr, text)
        if isstr == 2 then
            return text
        elseif isstr == 0 then
            if temp == "true" then
                return true
            elseif temp == "false" then
                return false
            else
                return tonumber(temp)
            end
        else
            raise(i, "str")
            return
        end
    end
    for i = 1, #s do
        current = string.sub(s, i, i)
        if skip then
            temp = temp .. current
            skip = false
        elseif current == "{" then
            -- 层数完成下移
            deep = deep + 1
            if tree[deep] == nil then
                table.insert(tree, {})
            end
            -- 标记本层为数组类型
            array[deep] = false
            temp = ""
        elseif current == "}" then
            -- 判断此层是否为数组，若是则弹出错误
            if array[deep] then
                raise(i, "}1")
                return
            end
            if temp ~= "" then
                -- 检查发现前面取出的 token 不为单数则抛出
                if #tree[deep]%2 == 0 then
                    raise(i, "}2")
                    return
                end
                table.insert(tree[deep], tovalue(isstr, temp))
                isstr = 0
            end
            -- 键值对包装
            now = {}
            for j = 1, #tree[deep] - 1, 2 do
                key = tree[deep][j]
                val = tree[deep][j + 1]
                now[key] = val
            end
            -- 若当前层数上移到达 0 ，判断为结束，直接返回
            if deep == 1 then
                return now
            end
            -- 键值对结束，包装好的键值对上移
            table.insert(tree[deep-1], now)
            -- 清空本层元素
            table.remove(tree, deep)
            -- 层数完成上移
            deep = deep - 1
            temp = ""
        elseif current == "[" then
            -- 层数完成下移
            deep = deep + 1
            if tree[deep] == nil then
                table.insert(tree, {})
            end
            -- 标记本层为数组类型
            array[deep] = true
            temp = ""
        elseif current == "]" then
            -- 判断此层是否为数组，若非则弹出错误
            if not array[deep] then
                raise(i, "]")
                return
            end
            if temp ~= "" then
                table.insert(tree[deep], tovalue(isstr, temp))
                isstr = 0
            end
            -- 若当前层数上移到达 0 ，判断为结束，直接返回
            if deep == 1 then
                return tree[deep]
            end
            -- 数组结束，本层元素上移
            table.insert(tree[deep-1], tree[deep])
            -- 清空本层元素
            table.remove(tree, deep)
            -- 层数完成上移
            deep = deep - 1
            temp = ""
        elseif current == ":" then
            -- 数组中不能出现 : 符号
            if array[deep] then
                raise(i, ":1")
                return
            end
            -- 检查发现前面取出的 token 不为双数则抛出
            if #tree[deep]%2 == 1 then
                raise(i, ":2")
                return
            end
            -- 如果 key 不为字符串则抛出
            if isstr ~= 2 then
                raise(i, "str")
                return
            end
            -- 该层数组内插入 Key 值
            table.insert(tree[deep], temp)
            isstr = 0
            temp = ""
        elseif current == "," then
            -- 该层为键值对类型时
            -- 检查发现前面取出的 token 不为单数则抛出
            if temp ~= "" then
                if not array[deep] and #tree[deep]%2 == 0 then
                    raise(i, ",")
                    return
                end
                -- 该层数组内插入 Value 值
                table.insert(tree[deep], tovalue(isstr, temp))
                isstr = 0
            end
            temp = ""
        elseif current == "\"" then
            isstr = isstr + 1
        elseif current == "\\" then
            skip = true
        else
            temp = temp .. current
        end
    end
    raise(#s, "not complete")
end

function dumps(obj)
    local cache = {}
    local array = 0
    local prefix = "{"
    local suffix = "}"
    local function escape(text) 
        return string.gsub(text,"\"", "\\\"")
    end
    if type(obj) == "table" then
        for k, v in pairs(obj) do
            if type(k) == "number" and k <= #obj then
                array = array + 1
                if type(v) == "table" then
                    table.insert(cache, dumps(v))
                elseif type(v) == "string" then
                    table.insert(cache, "\"" .. escape(v) .. "\"")
                else 
                    table.insert(cache, tostring(v))
                end
            elseif type(k) == "string" then
                if type(v) == "table" then
                    table.insert(cache, "\"" .. escape(k)  .. "\":" .. dumps(v))
                elseif type(v) == "string" then
                    table.insert(cache, "\"" .. escape(k) .. "\":" .. "\"" .. escape(v) .. "\"")
                else 
                    table.insert(cache, "\"" .. escape(k) .. "\":" .. tostring(v))
                end
            else
                raise(0, "key 不能为字符串以外的东西")
            end
        end
    end
    if #obj ~= 0 and array == #obj then
        prefix = "["
        suffix = "]"
    elseif #obj ~= 0 then 
        raise(0, "键值对数组杂糅")
    end
    return prefix .. table.concat(cache, ",") .. suffix
end

test = [[{"哈哈\"哈哈":124,"178":[123,234,false,true],"234":{"123":248}}]]
print(dumps(loads(test)))