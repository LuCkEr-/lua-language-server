local m = {}

m.cache = {}

--- `aaa/bbb/ccc.lua` 与 `?.lua` 将返回 `aaa.bbb.cccc`
local function getOnePath(path, searcher)
    local stemPath     = path
                        : gsub('%.[^%.]+$', '')
                        : gsub('[/\\]+', '.')
    local stemSearcher = searcher
                        : gsub('%.[^%.]+$', '')
                        : gsub('[/\\]+', '.')
    local start        = stemSearcher:match '()%?' or 1
    for pos = start, #stemPath do
        local word = stemPath:sub(start, pos)
        local newSearcher = stemSearcher:gsub('%?', word)
        if newSearcher == stemPath then
            return word
        end
    end
    return nil
end

function m.getVisiblePath(path, searchers)
    path = path:gsub('^[/\\]+', '')
    if not m.cache[path] then
        local result = {}
        m.cache[path] = result
        local pos = 1
        repeat
            local cutedPath = path:sub(pos)
            local head
            if pos > 1 then
                head = path:sub(1, pos - 1)
            end
            pos = path:match('[/\\]+()', pos)
            for _, searcher in ipairs(searchers) do
                local expect = getOnePath(cutedPath, searcher)
                if expect then
                    if head then
                        searcher = head .. searcher
                    end
                    result[#result+1] = {
                        searcher = searcher,
                        expect   = expect,
                    }
                end
            end
            if not pos then
                break
            end
        until not pos
    end
    return m.cache[path]
end

function m.flush()
    m.cache = {}
end

return m
