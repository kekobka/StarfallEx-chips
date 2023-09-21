local ASYNCTAME = {}
local function cback(co, ...)
    if coroutine.status(co.co or co) ~= "dead" then
        co(co, ...)
    end
end
function await(co, asyncfunc)
    asyncfunc.onFinish = function(...)
        coroutine.resume(co, ...)
    end
    if not asyncfunc.finished then
        coroutine.yield(asyncfunc)
    end
    return asyncfunc.ret
end
local asyncmeta = {
    __call = function(self, ...)
        local a = {coroutine.resume(self.co, ...)}
        local f = istable(a[1]) and a[1].co

        if not ASYNCTAME[f] then
            self.finished = true
            self.onFinish(unpack(a))
            self.ret = unpack(a)
            ASYNCTAME[self.co] = nil
        end
        return self
    end
}
function async(fn)
    local co
    co = coroutine.create(function(...)
        return fn(...)
    end)
    ASYNCTAME[co] = setmetatable({
        co = co,
        onFinish = function()
        end,
        finished = false
    }, asyncmeta)
    return ASYNCTAME[co]
end
function sleep(ms)
    local co = ASYNCTAME[coroutine.running()]
    timer.simple(ms / 1000, function()
        cback(co)
    end)
    coroutine.yield(co)
end
--- fetch
---@param url string
---@param options table
local asyncpost = async(http.post)
local asyncget = async(http.get)
function fetch(url, options)
    local co = ASYNCTAME[coroutine.running()]
    local cc = function(...)
        local args = {...}
        co({
            body = args[1],
            length = args[2],
            headers = args[3],
            code = args[4]
        })
    end
    options = options or {}
    if options.payload then
        http.post(url, options.payload, cc, cc, options.headers)
        return coroutine.yield(co)
    end
    http.get(url, cc, cc, options.headers)
    return coroutine.yield(co)
end

function soundLoad(url, flags)
    local co = coroutine.running()
    local cc = function(...)
        local args = {...}
        co({
            Bass = args[1],
            error = args[2],
            name = args[3]
        })
    end
    return async(bass.loadURL)(url, flags or "", cc)
end
