local sub, rep = string.sub, string.rep;
local insert, concat, remove = table.insert, table.concat, table.remove;

local function encode_error(err)
    error("\n" .. "An error has occurred during SlowJson encoding" .. "\n" .. err);
end

local function encoder(obj)
    if type(obj) ~= "table" then
        encode_error("Input should be a table");
        return ""
    end

    local cache = {}; -- 当前元素缓存
    local array = 0; -- 当前数组包含元素个数
    local prefix = "{"; -- 默认键值对类型开头
    local suffix = "}"; -- 默认键值对类型结尾

    -- 转义字符
    -- TODE: 暂时就这样吧
    local function escape(text)
        return string.gsub(text, "\"", "\\\"");
    end

    -- 开始遍历
    for k, v in pairs(obj) do
        if type(k) == "number" and k <= #obj then
            array = array + 1;
            if type(v) == "table" then
                table.insert(cache, encode(v));
            elseif type(v) == "string" then
                table.insert(cache, "\"" .. escape(v) .. "\"");
            else
                table.insert(cache, tostring(v));
            end
        elseif type(k) == "string" then
            if type(v) == "table" then
                table.insert(cache, "\"" .. escape(k) .. "\":" .. encode(v));
            elseif type(v) == "string" then
                table.insert(cache, "\"" .. escape(k) .. "\":" .. "\"" .. escape(v) .. "\"");
            else
                table.insert(cache, "\"" .. escape(k) .. "\":" .. tostring(v));
            end
        else
            encode_error("Key can not be a " .. type(k));
        end
    end
    if #obj ~= 0 and array == #obj then
        prefix = "[";
        suffix = "]";
    elseif #obj ~= 0 then
        encode_error("Missing key value");
    end
    return prefix .. table.concat(cache, ",") .. suffix;
end

return encoder;