local Button = require("./Button.lua")

local Combobox = class("VUI.Combobox", Button)

function Combobox:initialize(UI, b)
    Button.initialize(self, UI, true)
    self.alignX = 0
    self.alignY = 1
    self:setText("ComboBox")
    self:setSize(150, 24)
    self.list = self.UI:add("ListLayout")
    self.list:setY(24)
    -- self.list:setParent(self)
    self:closeList()
    if not b then
        self:init()
    end
    self.fonts = self.UI.FONTS
end
function Combobox:paint(x, y, w, h)
    local round = self:getRounded()
    render.setColor(self:getColorScheme("bghover"))
    render.drawRoundedBox(round, x, y, w, h)
    render.setColor(self:isHovered() and self:getColorScheme("bghover") or self:getColorScheme("bg"))
    render.drawRoundedBox(round, x + 1, y + 1, w - 2, h - 2)
    render.setColor(self:getColorScheme("text"))
    render.setFont(self._font)
    render.drawSimpleText(x + 1 + (self.alignX == 1 and w / 2 or 0), y + (self.alignY == 1 and h / 2 or 0), self._text, self.alignX, self.alignY)
    render.setColor(self:getColorScheme("text"))
    render.setFont(self.fonts.icons)
    render.drawSimpleText(x + w - 5, y + h / 2, string.utf8char(0xE700), 2, 1)
end
function Combobox:onMousePressed(x, y, key, keyName)

    if (key == MOUSE.MOUSE1 or key == MOUSE.MOUSE2) and not self._lock then
        self:setUsed(true)
        self:_onUse(true, x, y, key, keyName)
        self:onUse(true)
    end
end

function Combobox:openList()
    self.listVisible = true
    local x, y = self:getAbsolutePos()
    self.list:setPos(x, y + self:getH())
    self.list:setVisible(true)
    self.list:sizeToContents()
    self.list:getParent():moveToFront(self.list)
end
function Combobox:closeList()
    self.listVisible = false
    self.list:setVisible(false)
end

function Combobox:onMouseReleased(x, y, key, keyName)

    if (key == MOUSE.MOUSE1 or key == MOUSE.MOUSE2) and self:isUsed() then
        if key == MOUSE.MOUSE1 then
            self:onClick()
        elseif key == MOUSE.MOUSE2 then
            self:onRightClick()
        end

        self:setUsed(false)
        self:_onUse(false, x, y, key, keyName)
        self:onUse(false)
        if self.listVisible then
            self:closeList()
        else
            self:openList()
        end
    end
end

function Combobox:addLine(c)
    self.list:addLine(c)
    c._onUse = function(_, b)
        if not b then
            self:closeList()
        end
    end
end

function Combobox:getRounded()
    return self.UI._Skin.Combobox.rounded
end

function Combobox:performLayout(w, h)
    if not self.listVisible then
        return
    end
    local x, y = self:getAbsolutePos()
    self.list:setPos(x, y + self:getH())
    self.list:setVisible(true)
    self.list:getParent():moveToFront(self.list)
end

return Combobox
