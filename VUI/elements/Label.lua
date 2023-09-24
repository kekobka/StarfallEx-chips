local Label = class("VUI.Label", Element)

function Label:initialize(UI, b)
    Label.super.initialize(self, UI, true)
    self.alignX = 0
    self.alignX = 0
    self:setText("Label")
    self:setFont(self.UI.FONTS.main)
    self:sizeToContents()
    if not b then
        self:init()
    end
end
function Label:onMousePressed(x, y, key, keyName)

    if key == MOUSE.MOUSE1 or key == MOUSE.MOUSE2 and not self._lock then
        self:setUsed(true)
        self:_onUse(true, x, y, key, keyName)
        self:onUse(true)
    end
end
function Label:onMouseReleased(x, y, key, keyName)

    if (key == MOUSE.MOUSE1 or key == MOUSE.MOUSE2) and self:isUsed() then
        if key == MOUSE.MOUSE1 then
            self:onClick()
        elseif key == MOUSE.MOUSE2 then
            self:onRightClick()
        end

        self:setUsed(false)
        self:_onUse(false, x, y, key, keyName)
        self:onUse(false)
    end
end

function Label:paint(x, y, w, h)
    -- render.setRGBA(0, 0, 0, 255)
    -- render.drawRectFast(x, y, w, h)
    render.setColor(self:getColorScheme("text"))
    render.setFont(self._font)
    render.drawSimpleText(x, y, self._text, 0, 0)
end

function Label:setFont(font)
    self._font = font
    render.setFont(font)

    self._textWidth, self._textHeight = render.getTextSize(self._text)
    return self
end

function Label:getFont()
    return self._font
end
function Label:getColorScheme(type)
    return UI._Skin.Label[type]
end

function Label:setText(text)
    self._text = tostring(text)

    if self:getFont() then
        render.setFont(self:getFont())

        self._textWidth, self._textHeight = render.getTextSize(text)
    else
        render.setFont(render.getDefaultFont())
        self._textWidth, self._textHeight = render.getTextSize(text)
    end
    self:sizeToContents()
    return self
end

function Label:getTextSize()
    return self._textWidth, self._textHeight
end

function Label:getText()
    return self._text
end

function Label:sizeToContents()
    self:setSize(self:getTextSize())
end

function Label:_onUse(bool)

end
function Label:onClick()
end
function Label:onRightClick()
end

function Label:onUse(bool)
end
return Label
