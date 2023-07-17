--@name tab
--@author discord.gg/6Q5NnHQTrh // kekobka // STEAM_0:0:186583728


local E = require("./button.lua")
E:include(MIXIN)

local element = class("vTab",E)

function element:initialize(gui)
    E.initialize(self,gui)
    self:setText("Tab")
    self:setSize(100,24)
    self.tabchilds = {}
end

function element:onMouseReleased(x, y, key, keyName)
    if key == MOUSE.MOUSE1 and self:isUsed() then
        self:onClick()
        self:setUsed(false)
        self:onUse(false)
        self.lastx = x
        self.lasty = y
        self.aprogress = 0
        
        -- tab func
        
        self:getParent()._activetab = self
        
        self:getParent():updateTabs()
        
    end
end


function element:close()
    self:setEnabled(false)
    for idx,child in ipairs(self.tabchilds) do
        child:setVisible(true)
    end
    self:onClose()
end

function element:open()
    self:setEnabled(true)
    for idx,child in ipairs(self.tabchilds) do
        child:setVisible(false)
    end
    self:onOpen()
end

function element:add(child)
    table.insert(self.tabchilds,child)
end

function element:addChild(child)    
    local set = self:getParent()
    child:setParent(set)
    table.insert(self.tabchilds,child)
    if not set._firstChild then
        set._firstChild = child
    else
        local temp = set._firstChild
        
        while temp._nextSibling do
            temp = temp._nextSibling
        end
        
        temp._nextSibling = child
        child._prevSibling = temp
    end
    set:updateTabs()
end

-- STUB

function element:onClose()
end

function element:onOpen()
end



return element














































































