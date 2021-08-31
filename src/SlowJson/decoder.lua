local sub, rep = string.sub, string.rep;
local min, max = math.min, math.max;
local insert, concat, remove = table.insert, table.concat, table.remove;

local function decode_error(s, index, err)
    local start = max(1, index - 10);
    local finish = min(index + 10, #s);
    local near = sub(s, start, finish);
    error("\n" .. "An error has occurred during SlowJson decoding" .. "\n" .. near .. "\n" .. rep("-", index - start) ..
              "^" .. rep("-", finish - index) .. "\n" .. err);
end

local function decoder(s)
    if type(s) ~= "string" then
        decode_error("", 1, "Input should be a string");
        return;
    end

    -- 变量定义
    local cache = ""; -- 缓存 Token 
    local deep = 0; -- 指示当前层数
    local tree = {}; -- Token 树
    local array = {}; -- 指示层数为数组或者键值对
    local skip = false; -- 用于转义字符时候跳过
    local isstr = 0; -- 判断 Token 是否为字符串

    -- 类型转换，包括字符串、数值、布尔、None
    local function to_value(isstr, text)
        -- 为字符串
        if isstr == 2 then
            return text;
        end
        if isstr == 0 then
            -- 为布尔
            if text == "true" then
                return true;
            end
            if text == "false" then
                return false;
            end
            -- 为 None
            if text == "None" then
                return nil;
            end
            -- 为数值
            local num = tonumber(text);
            if num ~= nil then
                return num;
            end
        end
        return text;
    end

    -- 遍历字符串
    for i = 1, #s do
        -- 当前字符
        current = sub(s, i, i);
        -- 判断各种状态
        if skip then
            cache = cache .. current;
            skip = false;
        elseif current == "{" then
            -- 层数完成下移
            deep = deep + 1;
            if tree[deep] == nil then
                insert(tree, {});
            end
            -- 标记本层为数组类型
            array[deep] = false;
            cache = "";
        elseif current == "}" then
            -- 判断此层是否为数组，若是则弹出错误
            if array[deep] then
                decode_error(s, i, "SyntaxError end of JSON input");
                return;
            end
            if cache ~= "" then
                -- 检查发现前面取出的 token 不为单数则抛出
                if #tree[deep] % 2 == 0 then
                    decode_error(s, i, "SyntaxError end of JSON input");
                    return;
                end
                insert(tree[deep], to_value(isstr, cache));
                isstr = 0;
            end
            -- 键值对包装
            local now = {};
            for j = 1, #tree[deep] - 1, 2 do
                key = tree[deep][j];
                val = tree[deep][j + 1];
                now[key] = val;
            end
            -- 若当前层数上移到达 0 ，判断为结束，直接返回
            if deep == 1 then
                return now;
            end
            -- 键值对结束，包装好的键值对上移
            insert(tree[deep - 1], now);
            -- 清空本层元素
            remove(tree, deep);
            -- 层数完成上移
            deep = deep - 1;
            cache = "";
        elseif current == "[" then
            -- 层数完成下移
            deep = deep + 1;
            if tree[deep] == nil then
                insert(tree, {});
            end
            -- 标记本层为数组类型
            array[deep] = true;
            cache = "";
        elseif current == "]" then
            -- 判断此层是否为数组，若非则弹出错误
            if not array[deep] then
                decode_error(s, i, "SyntaxError end of JSON input");
                return;
            end
            if cache ~= "" then
                insert(tree[deep], to_value(isstr, cache));
                isstr = 0;
            end
            -- 若当前层数上移到达 0 ，判断为结束，直接返回
            if deep == 1 then
                return tree[deep];
            end
            -- 数组结束，本层元素上移
            insert(tree[deep - 1], tree[deep]);
            -- 清空本层元素
            remove(tree, deep);
            -- 层数完成上移
            deep = deep - 1;
            cache = "";
        elseif current == ":" then
            -- 数组中不能出现 : 符号
            if array[deep] then
                decode_error(s, i, "SyntaxError end of JSON input");
                return;
            end
            -- 检查发现前面取出的 token 不为双数则抛出
            if #tree[deep] % 2 == 1 then
                decode_error(s, i, "SyntaxError end of JSON input");
                return;
            end
            -- 如果 key 不为字符串则抛出
            if isstr ~= 2 then
                decode_error(s, i, "SyntaxError end of JSON input");
                return;
            end
            -- 该层数组内插入 Key 值
            insert(tree[deep], cache);
            isstr = 0;
            cache = "";
        elseif current == "," then
            -- 该层为键值对类型时
            -- 检查发现前面取出的 token 不为单数则抛出
            if cache ~= "" then
                if not array[deep] and #tree[deep] % 2 == 0 then
                    decode_error(s, i, "SyntaxError end of JSON input");
                    return;
                end
                -- 该层数组内插入 Value 值
                insert(tree[deep], to_value(isstr, cache));
                isstr = 0;
            end
            cache = "";
        elseif current == "\"" then
            if isstr == 0 then
                cache = "";
            end
            isstr = isstr + 1;
        elseif current == "\\" then
            skip = true;
        else
            if isstr == 0 then
                if current ~= " " and current ~= "\n" and current ~= "\r" and current ~= "\r\n" and current ~= "\t" then
                    cache = cache .. current;
                end
            elseif isstr == 1 then
                cache = cache .. current;
            end
        end
    end
    decode_error(s, #s, "SyntaxError end of JSON input");
end

return decoder;