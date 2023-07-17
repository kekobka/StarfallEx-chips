-- @name gui
-- @author valera 41 // kekobka // STEAM_0:0:186583728
-- @shared
-- if player() ~= owner() then return end

local function isURL(str)
    local _1, _2, prefix = str:find("^(%w-):")

    return prefix == "http" or prefix == "https" or prefix == "data"
end
local function canProcess()
    return math.max(cpuTotalAverage(), cpuTotalUsed() / 4) < cpuMax() * 0.7
end
local requireold = dofile
function require(dir) return requireold(dir) end

function accessorFunc(tbl, varName, name, defaultValue)
    tbl[varName] = defaultValue
    tbl["get" .. name] = function(self) return self[varName] end
    tbl["set" .. name] = function(self, value) self[varName] = value end
end

_G.DOCK = {FILL = 1, LEFT = 2, RIGHT = 3, TOP = 4, BOTTOM = 5}

_G.FILL = 1
_G.LEFT = 2
_G.RIGHT = 3
_G.TOP = 4
_G.BOTTOM = 5

local function async(a)
    local G = crc(tostring(a))
    local workers = {}
    hook.add("think", "async." .. G, function()
        for Key, work in ipairs(workers) do
            if not canProcess() then break end
            try(work(Key))
        end
    end)
    return function(...)
        local args = {...}
        table.insert(workers, function(Key)
            return coroutine.wrap(function()
                a(unpack(args))
                table.remove(workers, Key)
            end)
        end)
    end
end
local function queue(a)
    local G = crc(tostring(a))
    local workers = {}
    hook.add("think", "queue." .. G, function()
        for Key, work in ipairs(workers) do
            if not canProcess() or not pcall(work(Key)) then break end
        end
    end)
    return function(...)
        local args = {...}
        table.insert(workers, function(Key)
            return coroutine.wrap(function()
                a(unpack(args))
                table.remove(workers, Key)
            end)
        end)
    end
end
local http_ = table.copy(_G.http)
http.post = queue(function(...) http_.post(...) end)
http.get = queue(function(...) http_.get(...) end)

-- local elements = requireDir("./elements")
local vGui = class("vgui")
--@includedir ./elements
--@includedir ./skins
--@include ./styles.lua

require("./styles.lua")

local SKINS = {}
local ELEMENTS = {}
do
    local tbl = {}
    local skins = requiredir("./skins")
    for path, skin in pairs(skins) do
        tbl[string.getFileFromFilename(path):sub(0, -5)] = skin
    end
    vGui.static.skins = tbl
    local elements = requiredir("./elements")
    for path, data in pairs(elements) do
        ELEMENTS[string.lower(string.match(path, "/(%w+).lua$"))] = data
    end
end

function vGui:initialize(device)
    self._device = device
    local _root, _resx, _resy
    local elements = {}
    self.initialized = false
    self.matrix = Matrix()
    self.skin = self.class.static.skins["default"]
    local function set_element(element, code) elements[element] = code end
    local function http_retry(element, url)

        self.httpget(url, function(code)
            elements[element] = code
            if #elements == #ELEMENTS then initialize() end
        end, function()
            self.error("try download '" .. element .. "' element")
            http_retry(element, url)
        end)
    end
    if device == "hud" then
        _resx, _resy = render.getResolution()
    else
        _resx, _resy = 1024, 1024
    end

    function self:getResolution() return _resx, _resy end

    self.hint("Initialized")

    local _root = ELEMENTS.root:new(self)

    _root:setSize(self:getResolution())
    _root:setVisible(false)
    function self:getRoot() return _root end

    function self:setVisible(state) _root:setVisible(state) end

    function self:isVisible() return _root:isVisible() end

    local SCALE = (_resx / 1366)
    if device == "hud" then
        enableHud(owner(), true)
        hook.add("postdrawhud", "gui_renderer", function()
            if self:isVisible() then input.enableCursor(true) end
            if not hasPermission("input") or not input.getCursorVisible() then
                return
            end
            render.setFilterMag(1)
            render.setFilterMin(1)
            _root:_postEvent("PAINT")
        end)
    else
        render.createRenderTarget(table.address(self))
        hook.add("render", "gui_paint", function()
            render.clear(Color(0, 0, 0, 0))
            render.setFilterMag(1)
            render.setFilterMin(1)
            render.setRenderTargetTexture(table.address(self))
            render.drawTexturedRect(0, 0, render.getResolution())
        end)
        hook.add("renderoffscreen", "gui_renderer", function()
            render.selectRenderTarget(table.address(self))
            render.clear(Color(0, 0, 0), true)
            _root:_postEvent("PAINT")
            render.selectRenderTarget(nil)
        end)
    end
    local _lastMouseX = 0
    local _lastMouseY = 0
    self.openkey = "t"
    hook.add("inputPressed", "gui_inputPressed", function(key)

        if device == "hud" and input.getKeyName(key) == self.openkey then
            input.enableCursor(not input.getCursorVisible())
            self:setVisible(input.getCursorVisible())
        end
        if not hasPermission("input") or
            (device == "hud" and not input.getCursorVisible()) then
            return
        end
        local keyName = input.getKeyName(key)
        local x, y = self:getCursor()
        if not x or not y then return end
        if key >= 107 and key <= 111 and _root:isVisible() then

            _root:_postEvent("MOUSE_PRESSED", x, y, key, keyName)

        elseif key == MOUSE.MWHEELUP or key == MOUSE.MWHEELDOWN then

            hook.run("mousewheeled", (MOUSE.MWHEELUP and 1 or 0) -
                         (MOUSE.MWHEELDOWN and 1 or 0))

            _root:_postEvent("MOUSE_WHEELED", x, y, key, keyName)

        else
            hook.run("gui_BUTTON_PRESSED", key, keyName)
            _root:_postEvent("BUTTON_PRESSED", x, y, key, keyName)
        end

    end)

    hook.add("inputReleased", "gui_inputReleased", function(key)
        if not hasPermission("input") or
            (device == "hud" and not input.getCursorVisible()) then
            return
        end
        local keyName = input.getKeyName(key)
        if key == MOUSE.MWHEELUP or key == MOUSE.MWHEELDOWN then
            _root:_postEvent("MOUSE_RELEASED", x, y, key, keyName)
        end
        local x, y = self:getCursor()
        if key >= 107 and key <= 111 and _root:isVisible() then

            _root:_postEvent("MOUSE_RELEASED", x, y, key, keyName)

        elseif key == MOUSE.MWHEELUP or key == MOUSE.MWHEELDOWN then

            hook.run("gui_mousewheeled", (MOUSE.MWHEELUP and 1 or 0) -
                         (MOUSE.MWHEELDOWN and 1 or 0))

            _root:_postEvent("MOUSE_WHEELED", x, y, key, keyName)

        else
            _root:_postEvent("BUTTON_RELEASED", x, y, key, keyName)
        end
    end)
    hook.add("think", "gui_think", function()
        if not hasPermission("input") or
            (device == "hud" and not input.getCursorVisible()) then
            return
        end

        local x, y = self:getCursor()
        if x and y and (x ~= _lastMouseX or y ~= _lastMouseY) then
            _lastMouseX = x
            _lastMouseY = y
            hook.run("gui_mousemoved", x, y)
            _root:_postEvent("MOUSE_MOVED", x, y)
        end

        _root:_postEvent("THINK")
    end)
    self.initialized = true
    if self.init then
        timer.simple(0, function() self:init(self:getResolution()) end)
    end

end

function vGui.error(...)
    if CLIENT and hasPermission("notification") then
        notification.addLegacy("[GUI] ERROR", NOTIFY.ERROR, 3)
    end
    print(Color(255, 100, 100, 255), "[GUI] ", Color(255, 255, 255, 255), ...)
end

function vGui.httpget(url, callbackSuccess, callbackFail, headers)
    if CLIENT and hasPermission("notification") then
        notification.addLegacy("[GUI] DOWNLOAD", NOTIFY.HINT, 3)
    end

    http.get(url, function(...) callbackSuccess(...) end, function(...)
        vGui.error("HTTP", ...)
        callbackFail()
    end, headers)
end
function vGui.print(...)
    print(Color(100, 255, 100, 255), "[GUI] ", Color(255, 255, 255, 255), ...)
end
function vGui.hint(Text)
    if CLIENT and hasPermission("notification") then
        notification.addLegacy("[GUI] " .. Text, NOTIFY.HINT, 3)
    end
end
function vGui:getCursor()
    if self._device == "screen" then
        x, y = render.cursorPos(player(), chip():getLinkedComponents()[1])
        if not x or not y then x, y = 0, 0 end
        x, y = x * 2, y * 2
        return x, y
    else
        return input.getCursorPos()
    end
end

function vGui:add(name, parent, cl)
    assert(istable(ELEMENTS[string.lower(name)]), name .. " is not element")

    local el = ELEMENTS[string.lower(name)]:new(self)
    el:setSkin(self.skin)
    if parent then
        parent:addChild(el)
    else
        self:getRoot():addChild(el)
    end
    if cl then cl(el) end
    return el
end
function vGui:create(name, parent, cl)
    assert(istable(ELEMENTS[string.lower(name)]), name .. " is not element")
    local el = ELEMENTS[string.lower(name)]:new(self)
    if parent then parent:addChild(el) end
    if cl then cl(el) end
    return el
end

function vGui:setSkin(name)
    assert(istable(self.class.static.skins[name]), name .. " is not skin")
    self.skin = self.class.static.skins[name]
end
function vGui:openButton(b) self.openkey = b end

function vGui.register(name, mtable, root)

    assert(istable(ELEMENTS[string.lower(root)]), name .. " is not element")

    ELEMENTS[string.lower(name)] = table.merge(class(name,
                                                     ELEMENTS[string.lower(root)]),
                                               mtable)
end

return vGui -- require("vgui")

