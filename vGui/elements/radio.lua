--@name radio
--@author discord.gg/6Q5NnHQTrh // kekobka // STEAM_0:0:186583728


local E = require("./checkbox.lua")
local element = class("vRadio", E)

function element:initialize(gui)
    E.initialize(self,gui)
    self:setLabel("Radio")
end 
function element:paint(x, y, w, h)    
    
    render.setColor(self:isChecked() and self:getColorFromScheme("mark") or Color(0, 0, 0, 0))
    render.drawFilledCircle(x + w / 2, y + h / 2, w / 2 - 3, 6)
    
    render.setColor(self:getColorFromScheme("border"))
    render.drawCircle(x + w / 2, y + h / 2, w / 2)
    render.drawCircle(x + w / 2, y + h / 2, w / 2 - 1)
end




return element











































































