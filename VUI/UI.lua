---@include ./utils.lua
require("./utils.lua")

---@include ./Element.lua
Element = require("./Element.lua")
---@include ./Skin.lua

local huge = math.huge
UI = class("UI")
UI.Skin = require("./Skin.lua")
UI._Skin = UI.Skin({
    Main = {
        rounded = 6,
        bg = Color(40, 43, 48, 255),
        bghover = Color(66, 69, 73, 255),
        text = Color(240, 240, 240, 255),
        header = Color(94, 117, 198, 255)
    }
})
local ELEMENTS = {}
do
    ---@includedir ./elements
    local elements = requiredir("./elements")
    for path, data in pairs(elements) do
        ELEMENTS[string.lower(string.match(path, "/(%w+).lua$"))] = data
    end
end
Element = nil
local FONTS = {
    icons = render.createFont("Segoe MDL2 Assets", 18, 400, true, true, true, false, 0, true, 0),
    main = render.createFont("Calibri", 24, 400, true, true, true, false, 0, true, 0)
}

UI.FONTS = FONTS
UI._elements = ELEMENTS
local address = table.address

local ANIMATIONWORKERS = {}
hook.add("Think", "ANIMATIONWORKERS", function()
    for Key, work in ipairs(ANIMATIONWORKERS) do
        work(Key)
    end
end)
function UI:initialize(device)
    self.device = device
    self.openkey = "t"
    local _resx, _resy, _customRender = 1024, 1024, false

    local _root = ELEMENTS.root(self)
    local dummyclr = Color(0, 0, 0, 0)
    local function paint()
        _root:_postEventToAllReverseRender(0, 0, _resx, _resy)
    end
    self.paint = paint
    if CLIENT then
        if self.device == "hud" then
            _resx, _resy = render.getResolution()
            function self.render()
                paint()
            end
        else
            render.createRenderTarget(address(self))
            function self.preRender()
                render.selectRenderTarget(address(self))
                render.clear(dummyclr)
                paint()
                render.selectRenderTarget(nil)
            end
            function self.render()
                -- render.setFilterMag(1)
                -- render.setFilterMin(1)
                self.preRender()
                render.setRGBA(255, 255, 255, 255)
                render.setRenderTargetTexture(address(self))
                render.drawTexturedRect(0, 0, _resx / 2, _resy / 2)
            end
        end
        function self.setCustomRender(bool)
            _customRender = bool
        end
        function self.isCustomRender()
            return _customRender == true
        end
    end
    function self.getResolution()
        return Vector(_resx, _resy)
    end

    _root:setSize(_resx, _resy)
    _root:setVisible(false)
    self.Root = _root

    function self.setVisible(b)
        _root:setVisible(b)
    end
    hook.add("InputPressed", "VUI.InputPressed." .. address(self), function(key)

        if device == "hud" and input.getKeyName(key) == self.openkey then
            input.enableCursor(not input.getCursorVisible())
            self:setVisible(input.getCursorVisible())
        end
        if not hasPermission("input") or (device == "hud" and not input.getCursorVisible()) then
            return
        end
        local keyName = input.getKeyName(key)
        local x, y = self:getCursor()
        if not x or not y then
            return
        end
        if key >= 107 and key <= 111 and _root:isVisible() then

            _root:_postEvent(EVENT.MOUSE_PRESSED, x, y, key, keyName)

        elseif key == MOUSE.MWHEELUP or key == MOUSE.MWHEELDOWN then

            hook.run("VUI.mousewheeled", (MOUSE.MWHEELUP and 1 or 0) - (MOUSE.MWHEELDOWN and 1 or 0))

            _root:_postEvent(EVENT.MOUSE_WHEELED, x, y, key, keyName)

        else
            hook.run("gui_BUTTON_PRESSED", key, keyName)
            _root:_postEvent(EVENT.BUTTON_PRESSED, x, y, key, keyName)
        end

    end)

    hook.add("InputReleased", "VUI.InputReleased." .. address(self), function(key)
        if not hasPermission("input") or (device == "hud" and not input.getCursorVisible()) then
            return
        end
        local keyName = input.getKeyName(key)
        local x, y = self:getCursor()
        if key == MOUSE.MWHEELUP or key == MOUSE.MWHEELDOWN then
            _root:_postEvent(EVENT.MOUSE_RELEASED, x, y, key, keyName)
        end
        local x, y = self:getCursor()
        if key >= 107 and key <= 111 and _root:isVisible() then

            _root:_postEvent(EVENT.MOUSE_RELEASED, x, y, key, keyName)

        elseif key == MOUSE.MWHEELUP or key == MOUSE.MWHEELDOWN then

            hook.run("VUI.mousewheeled", (MOUSE.MWHEELUP and 1 or 0) - (MOUSE.MWHEELDOWN and 1 or 0))

            _root:_postEvent(EVENT.MOUSE_WHEELED, x, y, key, keyName)

        else
            _root:_postEvent(EVENT.BUTTON_RELEASED, x, y, key, keyName)
        end
    end)
    local _lastMouseX, _lastMouseY = 0, 0
    hook.add("Think", "VUI.Think." .. address(self), function()

        if not hasPermission("input") or (device == "hud" and not input.getCursorVisible()) then
            return
        end

        local x, y = self:getCursor()
        if huge == x or huge == y then return end
        if x and y and (x ~= _lastMouseX or y ~= _lastMouseY) then
            _lastMouseX = x
            _lastMouseY = y
            hook.run("VUI.mousemoved", x, y)
            _root:_postEvent(EVENT.MOUSE_MOVED, x, y)
        end

        _root:_postEvent(EVENT.THINK)
    end)
end
function UI:add(name)
    if not name then
        return
    end
    assert(istable(ELEMENTS[name:lower()]), name .. " is not element")
    local el = ELEMENTS[name:lower()](self)
    el.UI = self
    self.Root:addChild(el)
    return el
end
function UI:GenerateExample()
    local f = self:add("Frame")
    f:GenerateExample()
    return f
end
function UI.newAnimation(speed, delay, callback, finish)
    timer.simple(delay, function()
        local progress = 0
        table.insert(ANIMATIONWORKERS, function(Key)
            progress = progress + timer.frametime() * speed
            callback(progress)
            if progress >= 1 then
                table.remove(ANIMATIONWORKERS, Key)
                if finish then
                    finish()
                end
            end
        end)
    end)
end
function UI:getCursor()

    if self.device == "hud" then

        return input.getCursorPos()
    else
        local screen = player():getEyeTrace().Entity
        if not isValid(screen) then
            return huge, huge
        end
        if screen:getClass() ~= "starfall_screen" then
            return huge, huge
        end
        x, y = render.cursorPos(player(), screen)
        if not x or not y then
            x, y = huge, huge
        end
        x, y = x * 2, y * 2

        return x, y

    end
end
function UI.StaticTest()
    print("Elements: " .. table.count(ELEMENTS))
    UI.error("Test error")
    UI.print("Test print")
    UI.hint("Test hint")

end

function UI.register(name, mtable, root)

    assert(istable(ELEMENTS[string.lower(root)]), name .. " is not element")

    ELEMENTS[string.lower(name)] = table.merge(class(name, ELEMENTS[string.lower(root)]), mtable)
end

function UI.error(...)
    if CLIENT and hasPermission("notification") then
        notification.addLegacy("[VUI] ERROR", NOTIFY.ERROR, 3)
    end
    print(Color(255, 150, 150, 255), "[VUI] ", Color(255, 255, 255, 255), ...)
end
function UI.print(...)
    print(Color(150, 255, 150, 255), "[VUI] ", Color(255, 255, 255, 255), ...)
end
function UI.hint(Text)
    if CLIENT and hasPermission("notification") then
        notification.addLegacy("[VUI] " .. Text, NOTIFY.HINT, 3)
    end
end

return UI
