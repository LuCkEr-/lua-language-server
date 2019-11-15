local guide = require 'parser.guide'
local searcher = require 'searcher.searcher'

local function getLinks(root)
    local cache = {}
    guide.eachSourceType(root, 'call', function (source)
        local uris = searcher.getLinkUris(source)
        if uris then
            for i = 1, #uris do
                local uri = uris[i]
                if not cache[uri] then
                    cache[uri] = {}
                end
                cache[uri][#cache[uri]+1] = source
            end
        end
    end)
    return cache
end

function searcher.getLinks(source)
    source = guide.getRoot(source)
    local cache = searcher.cache.getLinks[source]
    if cache ~= nil then
        return cache
    end
    local unlock = searcher.lock('getLinks', source)
    if not unlock then
        return nil
    end
    local clock = os.clock()
    cache = getLinks(source) or false
    local passed = os.clock() - clock
    if passed > 0.1 then
        log.warn(('getLinks takes [%.3f] sec!'):format(passed))
    end
    searcher.cache.getLinks[source] = cache
    unlock()
    return cache
end
