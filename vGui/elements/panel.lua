--@name panel
--@author discord.gg/6Q5NnHQTrh // kekobka // STEAM_0:0:186583728


local E = require("./element.lua")
E:include(MIXIN)

local element = class("vPanel",E)
element.accessorFunc(element, "_parentLock", "ParentLock", false)
function element:initialize(gui)
    E.initialize(self,gui)
    self:notChangeColorBorderOnHover()
    self.title = self.gui:add("label",self)
    self.title:setFont(self.gui.skin.fonts["mainBold"])
    self.title:setPos(12, 8)
    self.title:lock()
    self.title:setAlign(0)
    self:setTitle("Panel")
    self.corners = {self:getRoundedCorners()}
    self.minimizeButton = self.gui:add("button",self)
    self.minimizeButton:setFont(self.gui.skin.fonts["icons"])
    self.minimizeButton:setText(string.utf8char(0xE921))
    self.minimizeButton:setSize(32, 32)
    self.minimizeButton:dockMargin(5,5,5,5)
    self.minimizeButton:setRadius(0)
    self.minimizeButton:setAlign(0)
    self.minimizeButton:setTextSize(21,21)
    self.minimizeButton.onClick = function()
        self:minimizeMaximize()
    end
    
    
    self.closeButton = self.gui:add("button",self)
    self.closeButton:setFont(self.gui.skin.fonts["icons"])
    self.closeButton:setText(string.utf8char(0xE8BB))
    self.closeButton:setSize(32, 32)
    self.closeButton:dockMargin(5,5,5,5)
    self.closeButton:setRadius(0)
    self.closeButton:setTextSize(21,21)
    self.closeButton:setAlign(0)
    
    self.closeButton.onClick = function()
        self:close()
    end
    self._dockPadding = {0,33,0,0}
    self._tabs = {}
    self._tabsoffsetW = 0
    self._activetab = nil
    local w,h = self.gui:getResolution()
    self:setSize(w/2,h/2)
    -- self:center()
end
function element:dockPadding(q,w,e,r)
    self._dockPadding = {q,33+w,e,r}
end
function element:setTitle(title)
    self.title:setText(title)
    self.title:sizeToContents()
end

function element:getTitle()
    return self.title:getText()
end
function element:addTab(tab)
    if #self._tabs == 0 then
        self._activetab = tab
    end
    table.insert(self._tabs,tab)
    tab:setPos(self._tabsoffsetW,0)
    
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
        
    end
end
function element:setMinimizable(state)
    self._minimizable = state

    self.minimizeButton:setEnabled(state)
    self.minimizeButton:setVisible(state)
end

function element:isMinimizable()
    return self._minimizable
end

function element:setCloseable(state)
    self._closeable = state
    
    self.closeButton:setEnabled(state)
    self.closeButton:setVisible(state)
end

function element:isMinimized()
    return self._minimized
end

function element:setMinimized(state)
    self._minimized = state
end

function element:isCloseable()
    return self._minimizable
end

function element:minimize()
    self._lastHeight = self:getH()

    self.minimizeButton:setText(string.utf8char(0xE922))
    self:setMinimized(true)
    
    self.minimizeButton:lock()
    
    local progress = 0
    self:AnimationThink(function()
        progress = math.min(progress + 0.05,1)
        local ease = math.easeInBack(progress)
        local progressValueH = math.remap(ease, 0, 1, self._lastHeight, 32)

        self:setH(progressValueH)
        if progress == 1 then 
            
            self.minimizeButton:unlock()
            if self.onMinimize then self:onMinimize() end
            
            
            return true 
        end
        return throw("progress")
    end)
    local child = self._firstChild
    while child do
        if child ~= self.title and child ~= self.minimizeButton and child ~= self.closeButton then
            child:setVisible(false)
        end

        child = child._nextSibling
    end
end
function element:minimizeForced()
    self._lastHeight = self:getH()

    self.minimizeButton:setText(string.utf8char(0xE922))
    self:setMinimized(true)
    self:setH(32)
    if self.onMinimize then self:onMinimize() end
    local child = self._firstChild
    while child do
        if child ~= self.title and child ~= self.minimizeButton and child ~= self.closeButton then
            child:setVisible(false)
        end

        child = child._nextSibling
    end
end

function element:maximize()
    self.minimizeButton:setText(string.utf8char(0xE921))
    self:setMinimized(false)
    if self.onMaximize then self:onMaximize() end
    self.minimizeButton:lock()
    local progress = 0
    self:AnimationThink(function()
        progress = math.min(progress + 0.05,1)
        local ease = math.easeOutBack(progress)
        local progressValueH = math.remap(ease, 0, 1, 34, self._lastHeight)

        self:setH(progressValueH)
        if progress == 1 then 
            
            self.minimizeButton:unlock()
            local child = self._firstChild
            while child do
                if child ~= self.title and child ~= self.minimizeButton and child ~= self.closeButton then
                    child:setVisible(true)
                end
        
                child = child._nextSibling
            end
            self:updateTabs()
            return true 
        end
        return throw("progress")
    end)
    


end

function element:minimizeMaximize()
    if self:isMinimized() then
        self:maximize()
    else
        self:minimize()
    end
end

function element:performLayout(w, h)
    local dx,dy,dw,dh = unpack(self._dockPadding)
    self.minimizeButton:setPos(w - 52 - dx, 6 - dy)
    self.closeButton:setPos(w - 26 - dx, 6 - dy)
    self.title:setPos(12 - dx, 8 - dy)
end

function element:close()
    self:setVisible(false)
    self:setEnabled(false)
    self:onClose()
end

function element:open()
    self:setVisible(true)
    self:setEnabled(true)
    self:onOpen()
end

function element:onMousePressed(x, y, key, keyName)
    if key == MOUSE.MOUSE1 then
        local aX, aY = self:getAbsolutePos()
        
        if self:isDraggable() and y < aY + 33 then
            self._dragStartPos = {x - self:getX(), y - self:getY()}
            
            hook.add("gui_mousemoved","event_listener."..table.address(self),function(x,y)
                self:onMouseMoved(x,y) 
            end)
            hook.add("inputReleased","event_listener."..table.address(self),function(key)
                local keyName = input.getKeyName(key)
                if key == MOUSE.MOUSE1 then 
                    self:onMouseReleased(x, y, key, keyName)
                end
            end)
        end
    end
end

function element:onMouseReleased(x, y, key, keyName)
    
    if key == MOUSE.MOUSE1 then
        if self:isDraggable() then
            self._dragStartPos = nil
            hook.remove("gui_mousemoved","event_listener."..table.address(self))
            hook.remove("inputReleased","event_listener."..table.address(self))
        end
    end
end

function element:onMouseMoved(x, y)
    if self._dragStartPos then
        local targetX, targetY = x - self._dragStartPos[1], y - self._dragStartPos[2]
        
        self:setPos(targetX, targetY)
        self:invalidateLayout()
    end
end

function element:paint(x, y, w, h)  

    local rTL, rTR, rBR, rBL = self:getRoundedCorners()
    
    
    if self:getRadius() > 0 and (rTL or rTR or rBR or rBL) then
        
        render.setColor(self:getColorFromScheme("bg"))
        render.drawRoundedBoxEx(self:getRadius(), x + 1, y + 33, w - 2, h - 34, false, rTR, rBL, rBR)
        
        render.setColor(self:getColorFromScheme("header"))
        render.drawRoundedBoxEx(self:getRadius(),x + 1, y + 1, w - 2, 32, rTL, rTR, false, false)

    else
        
        render.setColor(self:getColorFromScheme("bg"))
        render.drawRectFast(x, y + 33, w, h - 33)
        
        render.setColor(self:getColorFromScheme("header"))
        render.drawRectFast(x, y, w, 33)
        if self._activetab then
            render.setColor(self._activetab:getColorFromScheme("bg"))
            render.drawRectFast(x, y + 33 + self._activetab:getH(), w, h - 33 - self._activetab:getH())
        end
        
    end
end

function element:onClose()
end

function element:onOpen()
end


return element

















































































