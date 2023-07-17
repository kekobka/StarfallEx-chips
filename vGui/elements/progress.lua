--@name progress
--@author discord.gg/6Q5NnHQTrh // kekobka // STEAM_0:0:186583728


local E = require("./label.lua")
E:include(MIXIN)

local element = class("vProgress",E)

function element:initialize(gui)
    E.initialize(self,gui)
    self._value = nil
    self:setSize(100,16)

end

function element:setValue(v)
    if self._value ~= v then
        self:onChange(self,_value,v)
    end
    self._value = v
end

function element:getValue()
    return self._value
end

function element:paint(x, y, w, h)
    
    render.setColor(self:getColorFromScheme("border"))
    render.drawRectOutline(x, y, w, h, 2)
    
    if self._value then
        render.drawRectFast(x + 4, y + 4, (w - 8) * self._value, h - 8)
    else
        local size = w / 3  - 8
        local t_phase = (timer.realtime() % 1)
        local t_start = x + 4 + ( (w - 8) * t_phase)
        local t_size = math.min( (x + w) - t_start, size)

        render.drawRectFast(t_start, y + 4, t_size - 4, h - 8)
        if t_size < size then
            render.drawRectFast(x + 4, y + 4, size - t_size, h - 8)
        end
    end
end


-- STUB

function element:onChange(old,new)
end


return element

















































































