local Label = require("./Label.lua")

local Button = class("VUI.Button", Label)

accessorFunc(Element, "m_bDrawBorder", "DrawBorder", true)

function Button:initialize(UI)
    Label.initialize(self, UI)
    self.alignX = 1
    self.alignY = 1
    self:setText("Button")
    self:setSize(100, 48)
end
function Button:paint(x, y, w, h)
    local round = self:getRounded()
    if self.m_bDrawBorder then
        render.setColor(self:getColorScheme("bghover"))
        render.drawRoundedBox(round, x, y, w, h)
    end
    render.setColor(self:isHovered() and self:getColorScheme("bghover") or self:getColorScheme("bg"))
    render.drawRoundedBox(round, x + 1, y + 1, w - 2, h - 2)
    render.setColor(self:getColorScheme("text"))
    render.setFont(self._font)
    render.drawSimpleText(x + (self.alignX == 1 and w / 2 or 0), y + (self.alignY == 1 and h / 2 or 0), self._text, self.alignX, self.alignY)
end
function Button:getRounded()
    return UI._Skin.Button.rounded
end
function Button:onMousePressed(x, y, key, keyName)

    if key == MOUSE.MOUSE1 or key == MOUSE.MOUSE2 and not self._lock then
        self:setUsed(true)
        self:_onUse(true, x, y, key, keyName)
        self:onUse(true)
    end
end

function Button:setText(text)
    self._text = tostring(text)

    if self:getFont() then
        render.setFont(self:getFont())

        self._textWidth, self._textHeight = render.getTextSize(text)
    else
        render.setFont(render.getDefaultFont())
        self._textWidth, self._textHeight = render.getTextSize(text)
    end
    return self
end
function Button:onMouseReleased(x, y, key, keyName)

    if (key == MOUSE.MOUSE1 or key == MOUSE.MOUSE2) and self:isUsed() then
        if key == MOUSE.MOUSE1 then
            self:onClick()
        elseif key == MOUSE.MOUSE2 then
            self:onRightClick()
        end

        self:setUsed(false)
        self:_onUse(false, x, y, key, keyName)
        self:onUse(false)
        self.lastx = x
        self.lasty = y
        self.aprogress = 0
    end
end

function Button:onClick()
end
function Button:onRightClick()
end

function Button:setAlign(xy)
    self.alignX = xy
    self.alignY = xy
end
function Button:setAlignX(X)
    self.alignX = X
end
function Button:setAlignY(Y)
    self.alignY = Y
end



return Button
