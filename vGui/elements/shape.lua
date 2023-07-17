--@name shape
--@author discord.gg/6Q5NnHQTrh // kekobka // STEAM_0:0:186583728


local E = require("./element.lua")
E:include(MIXIN)
local element = class("vShape", E)
element.accessorFunc(element, "_color", "Color", nil)
function element:paint(x, y, w, h)    
    render.setColor(self:getColor() or self:getColorFromScheme("bg"))
    render.drawRectFast(x, y, w, h)
end



return element













































































