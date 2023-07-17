--@name tabholder
--@author discord.gg/6Q5NnHQTrh // kekobka // STEAM_0:0:186583728


local E = require("./label.lua")
E:include(MIXIN)

local element = class("vTabHolder",E)

function element:initialize(gui)
    E.initialize(self,gui)
    self._tabs = {}
    self._tabsoffsetW = 0
    self._activetab = nil
    self:dockPadding(0,24,0,0)
end
function element:addTab(tab)
    if #self._tabs == 0 then
        self._activetab = tab
    end
    table.insert(self._tabs,tab)
    tab:setPos(self._tabsoffsetW-self._dockPadding[1],0)
    
    self._tabsoffsetW = self._tabsoffsetW + tab:getSize()
    self:updateTabs()
end
function element:updateTabs()
    for idx,tab in ipairs(self._tabs) do
        
        if tab == self._activetab then
            tab:close()
        else
            tab:open()
        end

        tab:setY(-self._dockPadding[2])
        tab:setH(self._dockPadding[2])
    end
    self:getParent():moveToFront(self)
end
function element:addChild(child)    
    
    child:setParent(self)
    
    if not self._firstChild then
        self._firstChild = child
    else
        local temp = self._firstChild
        
        while temp._nextSibling do
            temp = temp._nextSibling
        end
        
        temp._nextSibling = child
        child._prevSibling = temp
    end
    self:addTab(child)
    self:updateTabs()
end

function element:paint(x, y, w, h)  
    if self._activetab then
        render.setColor(self._activetab:getColorFromScheme("bg"))
        render.drawRectFast(x, y + self._activetab:getH(), w, h - self._activetab:getH())
    end
    
end

-- STUB

function element:onClick()
end
function element:onUse(bool)
end



return element














































































