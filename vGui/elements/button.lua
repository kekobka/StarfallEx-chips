--@name button
--@author discord.gg/6Q5NnHQTrh // kekobka // STEAM_0:0:186583728


local E = require("./label.lua")
E:include(MIXIN)

local element = class("vButton",E)

element.static.accessorFunc(element, "m_bDrawBorder", "DrawBorder", true)

function element:initialize(gui)
    E.initialize(self,gui)
    
    self:setFont(self.gui.skin.fonts["main"])
    self:setText("Button")
    self:setSize(100,32)
    self.aprogress = 0
end

element.setLabel = element.setText

function element:onMousePressed(x, y, key, keyName)
    if key == MOUSE.MOUSE1 or key == MOUSE.MOUSE2 and not self._lock then
        self:setUsed(true)
        self:onUse(true)
    end
end

function element:onMouseReleased(x, y, key, keyName)
    if key == MOUSE.MOUSE1 or key == MOUSE.MOUSE2 and self:isUsed() then
        if key == MOUSE.MOUSE1 then
            self:onClick()
        elseif key == MOUSE.MOUSE2 then
            self:onRightClick()
        end
        
        self:setUsed(false)
        self:onUse(false)
        self.lastx = x
        self.lasty = y
        self.aprogress = 0
    end
end

function element:onMouseLeave()
    self:setUsed(false)
end


function element:paint(x, y, w, h)
    local rTL, rTR, rBR, rBL = self:getRoundedCorners()
    
    if self:getRadius() > 0 and (rTL or rTR or rBR or rBL) then
        render.setColor(self:getColorFromScheme("bg"))
        render.drawRoundedBoxEx(self:getRadius(), x, y, w, h, rTL, rTR, rBL, rBR)
    else
        render.setColor(self:getColorFromScheme("bg"))
        render.drawRectFast(x, y, w, h)
        if self:getDrawBorder() then
            render.setColor(self:getColorFromScheme("border"))
            render.drawRectOutline(x, y, w, h, 2)
        end
    end
    if self.lastx and self.lasty then
        self.aprogress = math.min(self.aprogress + 4 * timer.frametime(),1)
        local R = math.remap(math.easeInSine(self.aprogress), 0, 1, 0, w+h)
        render.drawFilledCircle(self.lastx,self.lasty,R)
        if self.aprogress == 1 then 
            self.lastx, self.lasty  = nil,nil
            self.aprogress = 0
        end
    end
    self.textmatrix:setTranslation(Vector(x+(self._align == 1 and w/2 or 0),y+(self._aligny == 1 and h/2 or 0)))
    self.textmatrix:setScale(Vector(self._textW/255*2,self._textH/255*2,0))
    render.pushMatrix(self.textmatrix)
    
    render.setFont(self:getFont())
    render.setColor(self:getColorFromScheme("text"))
    render.drawSimpleText(0, 0, self:getText(),self._align,self._aligny)
    
    render.popMatrix(self.textmatrix)
end

-- STUB

function element:onClick()
end
function element:onRightClick()
end
function element:onUse(bool)
end



return element














































































