--@name slider
--@author discord.gg/6Q5NnHQTrh // kekobka // STEAM_0:0:186583728


local E = require("./label.lua")
E:include(MIXIN)

local element = class("vSlider",E)

function element:initialize(gui)
    E.initialize(self,gui)
    self._value = 0
    self:setSize(100,16)
end

function element:setValue(v)
    self._value = v
end

function element:getValue()
    return self._value
end

function element:onMousePressed(x, y, key, keyName)
    if key == MOUSE.MOUSE1 then
        self:setUsed(true)
        local px,py = self:getAbsolutePos()
        local w,h = self:getSize()
        local a = math.clamp(math.remap(x,px,px+w,0,1),0,1)
        if a ~= self:getValue() then
            self:setValue(a)
            self:onChange(self:getValue())
        end
        hook.add("inputReleased","event_listener."..table.address(self),function(key)
            local keyName = input.getKeyName(key)
            if key == MOUSE.MOUSE1 then 
                self:onMouseReleased(x, y, key, keyName)
            end
        end)
    end
end

function element:onMouseReleased(x, y, key, keyName)
    if key == MOUSE.MOUSE1 then
        self:setUsed(false)
        hook.remove("inputReleased","event_listener."..table.address(self))
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
        local px,py = self:getAbsolutePos()
        local w,h = self:getSize()

        local a = math.clamp(math.remap(x,px,px+w,0,1),0,1)
        if a ~= self:getValue() then
            self:setValue(a)
            self:onChange(self:getValue())
        end
    end
end

function element:paint(x, y, w, h)
    local st = Vector(x,y)

    render.setColor(self:getColorFromScheme("mark"))
    render.drawRectFast(x+4,  y+4, ( w - 8 ) * self:getValue(), h - 8)

    
    render.setColor(self:getColorFromScheme("border"))
    render.drawRectOutline(x, y, w, h, 2)
    
end

-- STUB

function element:onChange(state)
end


return element



























































