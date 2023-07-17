--@name listview
--@author discord.gg/6Q5NnHQTrh // kekobka // STEAM_0:0:186583728


local E = require("./label.lua")
E:include(MIXIN)

local element = class("vListView",E)

function element:initialize(gui)
    E.initialize(self, gui)
    self._tabs = {}
    self._offsetH = 0
    self._taboffsetH = 0
    self._selected = nil
    self:dockPadding(0, 24, 0, 0)
    self.scroll = self.gui:add("bslider", self)
    self.scroll:setSize(24,0)
    self.scroll:dock(RIGHT)
    self.scroll:setHorizontal()
    function self.scroll.onChange(scroll, value)
        self._offsetH = value
        self:invalidateLayout()
    end

end

function element:onMouseWheeled(x, y, key, keyName)
    if key == MOUSE.MWHEELUP then
        self._offsetH = self._offsetH + 0.01
    else
        self._offsetH = self._offsetH - 0.01
    end
    self:invalidateLayout()
end

function element:addColumn( column, position )
    -- :(
end

function element:addLine( id, text )
    local el = self.gui:add("button",self)
    self._tabs[id] = el
    el:setSize(self:getW() - 24, 24)
    el:setPos(0, self._taboffsetH)
    el:setText(text)
    function el.onClick(el)
        self._selected = el
        self:onSelected(id, text, el)
        for id,el in pairs(self._tabs) do
            el:setEnabled(true)
        end
        el:setEnabled(false)
    end
    function el.onMouseWheeled(el, x, y, key, keyName)
        if key == MOUSE.MWHEELUP then
            self._offsetH = self._offsetH + 0.01
        else
            self._offsetH = self._offsetH - 0.01
        end
        self:invalidateLayout()
    end
    self._taboffsetH = self._taboffsetH + 24        
    if el:getY() + el:getH() > self:getH() - 24 then
        el:setVisible(false)
    end
    self:invalidateLayout()
end

function element:editLine( id, text )
    self._tabs[id]:setText(text)
end
function element:isValid( id )
    return self._tabs[id] ~= nil
end

function element:removeById( id )
    self._tabs[id]:remove()
    self._tabs[id] = nil
    self._taboffsetH = self._taboffsetH - 24  
    self:invalidateLayout()
end
function element:clear( ... )
    for id,tab in pairs(self._tabs) do
        tab:remove()
        self._tabs[id] = nil
    end
    self._taboffsetH = 0 
    self:invalidateLayout()
end


function element:paint(x, y, w, h)  

    render.setColor(self:getColorFromScheme("bg"))
    render.drawRectFast(x, y, w, h)
    
    self.textmatrix:setTranslation(Vector(x + w / 2, y + 12))
    self.textmatrix:setScale(Vector(self._textW / 255 *2 ,self._textH / 255 * 2, 0))

    render.pushMatrix(self.textmatrix)
    
    render.setFont(self:getFont())
    render.setColor(self:getColorFromScheme("text"))
    render.drawSimpleText(0, 0, self:getText(), self._align, self._align)
    
    render.popMatrix(self.textmatrix)
end

function element:performLayout(w, h)
    if not self.scroll then return end
    self._offsetH = math.clamp(self._offsetH, 0, 1)
    self.scroll:dock(RIGHT, true)
    local offset = -self._offsetH * math.max(0, ( self._taboffsetH - h + 24 ) )
    for idx, el in pairs(self._tabs) do
        el:setPos(0,offset)
        offset = offset + 24      
        if el:getY() + el:getH() > self:getH() - 24 or el:getY() < 24 - el:getH() then
            el:setVisible(false)
        else
            el:setVisible(true)
        end
    end
end

-- STUB

function element:onSelected(id,text,button)
end



return element














































































