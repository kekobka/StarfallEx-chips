--@name textentry
--@author discord.gg/6Q5NnHQTrh // kekobka // STEAM_0:0:186583728


local E = require("./label.lua")
E:include(MIXIN)


local element = class("vTextentry",E)

element.accessorFunc(element, "_placeholder", "Placeholder", "textentry")

function element:initialize(gui)
    E.initialize(self,gui)
    
    self:setFont(self.gui.skin.fonts["textentry"])
    self:setText(self:getPlaceholder())
    self:setSize(100,32)
    
end

function element:onMousePressed(x, y, key, keyName)
    if key == MOUSE.MOUSE1 and not self._lock then
        self:setUsed(true)
    end
end

function element:onMouseReleased(x, y, key, keyName)
    if key == MOUSE.MOUSE1 and self:isUsed() then
        self:onClick()
        self:setText("OPEN CHAT")
        hook.add("StartChat","event_listener."..table.address(self),function(key, keyName)
            hook.add("ChatTextChanged","event_listener."..table.address(self),function(text)
                self:setText(text)
            end)
            hook.add("FinishChat","event_listener."..table.address(self),function(text)
                hook.remove("StartChat","event_listener."..table.address(self))
                hook.remove("ChatTextChanged","event_listener."..table.address(self))
                hook.remove("FinishChat","event_listener."..table.address(self))
                if self:getText() == "" then
                    self:setText(self:getPlaceholder())
                else
                    self:onFinish(self:getText())
                end
            end)
        end)
        self:setUsed(false)
    end
end

function element:onMouseLeave()
    self:setUsed(false)
end

function element:onFinish()
end


function element:paint(x, y, w, h)
    local rTL, rTR, rBR, rBL = self:getRoundedCorners()

    if self:getRadius() > 0 and (rTL or rTR or rBR or rBL) then
        render.setColor(self:getColorFromScheme("bg"))
        render.drawRoundedBoxEx(self:getRadius(), x, y, w, h, rTL, rTR, rBL, rBR)
    else
        render.setColor(self:getColorFromScheme("bg"))
        render.drawRectFast(x, y, w, h)
        
        render.setColor(self:getColorFromScheme("border"))
        render.drawRectOutline(x, y, w, h,2)
    end

    render.setFont(self:getFont())
    render.setColor(self:getColorFromScheme("text"))
    render.drawSimpleText(x+(self._align == 1 and w/2 or 0), y+(self._align == 1 and h/2 or 0), self:getText(),self._align,self._align)
    
end
-- STUB

function element:onClick()
end
function element:onChange()
end


return element
