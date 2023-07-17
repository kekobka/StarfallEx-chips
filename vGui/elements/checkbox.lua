--@name checkbox
--@author discord.gg/6Q5NnHQTrh // kekobka // STEAM_0:0:186583728


local vLabel = require("./label.lua")
local E = require("./element.lua")
E:include(MIXIN)

local element = class("vCheckbox",E)

element.static.accessorFunc(element, "_indent", "Indent", 8)

function element:initialize(gui)
    E.initialize(self,gui)
    
    self:setSize(16,16)

    self._checked = false
    
end

function element:setChecked(state)
    self._checked = state
    
    self:onChange(state)
end

function element:addLabel(title)
    if self.label then return self.label end
    self.label = self.gui:add("label",self)//vLabel:new(self.gui)
    self.label:setFont(self.gui.skin.fonts["mainBold"])
    self.label:setPos(16, 0)
    self.label:lock()
    self.label:setAlign(0)
    self:setLabel("Checkbox")
    return self.label
end

function element:setLabel(title)
    if not self.label then
        self:addLabel(title)
    end
    self.label:setText(title)
    self.label:sizeToContents()
end

function element:getLabel()
    return self.label:getText()
end
function element:addAnimation(...)
    if not self.label then return end
    return self.label:addAnimation(...)
end

function element:isChecked()
    return self._checked
end

function element:toggle()
    self:setChecked(!self:isChecked())
end

function element:performLayout(w, h)
    if not self.label then return end
    self.label:sizeToContents()
    self.label:setX(self:getW() + self:getIndent())
end

function element:onMousePressed(x, y, key, keyName)
    if key == MOUSE.MOUSE1 then
        self:toggle()
    end
end

function element:paint(x, y, w, h)    
    render.setColor(self:isChecked() and self:getColorFromScheme("mark") or Color(0, 0, 0, 0))
    render.drawRectFast(x + 4, y + 4, w - 8, h - 8)
    
    render.setColor(self:getColorFromScheme("border"))
    render.drawRectOutline(x, y, w, h, 2)
end

-- STUB

function element:onChange(state)
end

return element






























































































