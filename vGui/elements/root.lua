--@name root
--@author discord.gg/6Q5NnHQTrh // kekobka // STEAM_0:0:186583728


local E = require("./element.lua")
local element = class("vRoot",E)

function element:initialize(gui)
    E.initialize(self,gui)
    self.GUI = gui
    self.menu = nil
end

-- function element:onMousePressed(x, y, key, keyName)
--     if key == MOUSE.MOUSE2 and not self._lock then
--         self:setUsed(true)
--     end
-- end

-- function element:onMouseReleased(x, y, key, keyName)
--     if key == MOUSE.MOUSE2 and self:isUsed() then
--             if self.menu then
--                 self.menu:remove()
--             end
--             self.menu = self.gui:add("menu")
--             self.menu:addSpacer()
--             self.menu:open( x, y, false, self )
--             local option = self.menu:addOption( "awd", function() self.menu:remove() end )
--             self.menu:setTall(1000)
--         self:setUsed(false)
--     end
-- end



return element











































































