---@name bslider
---@author discord.gg/6Q5NnHQTrh // kekobka // STEAM_0:0:186583728
local vButton = require("./button.lua")
local E = require("./label.lua")
E:include(MIXIN)

local element = class("vButtonSlider", E)

function element:initialize(gui)
    E.initialize(self, gui)
    self._value = 0
    self.button = self.gui:add("button", self)
    self:setSize(100, 16)
    self.button:setText("")
    self.button:setPos(4, 4)
    self.button:lock()
    self._horizontal = false
    function self.button.onMousePressed(but, x, y, key, keyName)
        self:setUsed(true)
        self.button:setUsed(true)
        local px, py = self:getAbsolutePos()
        local w, h = self:getSize()
        local a
        if self._horizontal then
            a = math.clamp(math.remap(y + 4, py + h / 4, py + h - 4 - h / 4 + h / 8, 0, 1), 0, 1)
        else
            a = math.clamp(math.remap(x + 4, px + w / 4, px + w - 4 - w / 4 + w / 8, 0, 1), 0, 1)
        end
        self:setValue(a)
        hook.add("inputReleased", "event_listener." .. table.address(self), function(key)
            local keyName = input.getKeyName(key)
            if key == MOUSE.MOUSE1 then
                self.button.onMouseReleased(but, x, y, key, keyName)
            end
        end)
    end

    function self.button.onMouseReleased(but, x, y, key, keyName)
        self:setUsed(false)
        self.button:setUsed(false)
        hook.remove("inputReleased", "event_listener." .. table.address(self))
    end

    function self.button:onMouseLeave()
    end

end

function element:setHorizontal()
    self._horizontal = true
    self.button:setSize(w - 8 - self._dockMargin[3], h / 4 - self._dockMargin[4])
    self:invalidateLayout()
end

function element:setValue(v)
    local w, h = self:getSize()
    -- if self._value ~= v then
    self:onChange(self:getValue())
    -- end
    self._value = math.clamp(v, 0, 1)

end

function element:getValue()
    return self._value
end

function element:onMousePressed(x, y, key, keyName)
    if key == MOUSE.MOUSE1 then
        self.button:onMousePressed(x, y, key, keyName)
    end
end

function element:onMouseWheeled(x, y, key, keyName)
    if key == MOUSE.MWHEELUP then
        self:setValue(self:getValue() + 0.01)
    else
        self:setValue(self:getValue() - 0.01)
    end
end

function element:onMouseMoved(x, y)
    if self:isUsed() then
        local px, py = self:getAbsolutePos()
        local w, h = self:getSize()
        local a
        if self._horizontal then
            a = math.clamp(math.remap(y + 4, py + h / 4, py + h - 4 - h / 4 + h / 8, 0, 1), 0, 1)
        else
            a = math.clamp(math.remap(x + 4, px + w / 4, px + w - 4 - w / 4 + w / 8, 0, 1), 0, 1)
        end
        self:setValue(a)
    end
end

function element:paint(x, y, w, h)

    render.setColor(self:getColorFromScheme("border"))
    render.drawRectOutline(x, y, w, h, 2)

end
function element:performLayout(w, h)
    if not self.button then
        return
    end
    if self._horizontal then
        self.button:setSize(w - 8, h / 4)
        self.button:setPos(4, math.clamp(math.remap(self._value, 0, 1, 4, h - 4 - h / 4), 4, h - h / 4))
    else
        self.button:setSize(w / 4, h - 8)
        self.button:setPos(math.clamp(math.remap(self._value, 0, 1, 4, w - 4 - w / 4), 4, w - w / 4), 4)
    end

end

-- STUB

function element:onChange(state)
end

return element

