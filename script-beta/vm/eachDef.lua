local vm    = require 'vm.vm'
local guide = require 'parser.guide'
local files = require 'files'
local util  = require 'utility'
local await = require 'await'

local m = {}

function m.eachDef(source, results)
    results = results or {}
    local lock = vm.lock('eachDef', source)
    if not lock then
        return results
    end

    await.delay()

    local clock = os.clock()
    local myResults, count = guide.requestDefinition(source, vm.interface)
    if DEVELOP and os.clock() - clock > 0.1 then
        log.warn('requestDefinition', count, os.clock() - clock, guide.getUri(source), util.dump(source, { deep = 1 }))
    end
    vm.mergeResults(results, myResults)

    lock()

    return results
end

function vm.getDefs(source)
    local cache = vm.getCache('eachDef')[source] or m.eachDef(source)
    vm.getCache('eachDef')[source] = cache
    return cache
end

function vm.eachDef(source, callback)
    local results = vm.getDefs(source)
    for i = 1, #results do
        callback(results[i])
    end
end
