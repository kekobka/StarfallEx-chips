local Label = require("elements/Label")

local TextEntry = class("VUI.TextEntry", Label)

accessorFunc(TextEntry, "m_bPlaceholder", "Placeholder", "TextEntry")
accessorFunc(TextEntry, "m_bXOffset", "XOffset", 1)
accessorFunc(TextEntry, "m_bYOffset", "YOffset", 0)

function TextEntry:initialize(UI)
    Label.initialize(self, UI)
    self.alignX = 0
    self.alignY = 1
    self:setText(self:getPlaceholder())
    self:setSize(100, 48)
end

function TextEntry:paint(x, y, w, h)
    local round = self:getRounded()
    render.setColor(self:getColorScheme("bghover"))
    render.drawRoundedBox(round, x, y, w, h)
    render.setColor(self:isHovered() and self:getColorScheme("bghover") or self:getColorScheme("bg"))
    render.drawRoundedBox(round, x + 1, y + 1, w - 2, h - 2)
    render.setColor(self:getColorScheme("text"))
    render.setFont(self._font)
    local Xal = 0
    if self.alignX == 1 then 
        Xal = w / 2
    elseif self.alignX == 2 then 
        Xal = w  - 2
    end
    local Yal = 0
    if self.alignY == 1 then 
        Yal = h / 2
    elseif self.alignY == 2 then 
        Yal = h / 2
    end
    render.drawSimpleText(self.m_bXOffset + x + Xal, y + Yal + self.m_bYOffset, self._text, self.alignX, self.alignY)
end

function TextEntry:onMousePressed(x, y, key, keyName)
    if key == MOUSE.MOUSE1 and not self._lock then
        self:setUsed(true)
    end
end

function TextEntry:onMouseReleased(x, y, key, keyName)
    if key == MOUSE.MOUSE1 and self:isUsed() then
        self:onClick()
        self:setText("OPEN CHAT")
        local address = table.address(self)
        hook.add("StartChat", "VUI.event_listener." .. address, function(key, keyName)
            hook.add("ChatTextChanged", "VUI.event_listener." .. address, function(text)
                self:setText(text)
            end)
            hook.add("FinishChat", "VUI.event_listener." .. address, function(text)
                hook.remove("StartChat", "VUI.event_listener." .. address)
                hook.remove("ChatTextChanged", "VUI.event_listener." .. address)
                hook.remove("FinishChat", "VUI.event_listener." .. address)
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
function TextEntry:onMouseLeave()
    self:setUsed(false)
end
function TextEntry:getRounded()
    return self.UI._Skin.TextEntry.rounded
end
function TextEntry:setText(text)
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

function TextEntry:onFinish(text)
end
return TextEntry
