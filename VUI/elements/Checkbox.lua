-- local Label = require("./Label.lua")

local Checkbox = class("VUI.Checkbox", Element)

function Checkbox:initialize()
    Checkbox.super.initialize(self)
    self._checked = false
    self:setSize(16, 16)
end
function Checkbox:paint(x, y, w, h)
    local round = self:getRounded()
    render.setColor(self:getColorScheme("bghover"))
    render.drawRoundedBox(round, x, y, w, h)
    render.setColor(self:isHovered() and self:getColorScheme("bghover") or self:getColorScheme("bg"))
    render.drawRoundedBox(round, x + 1, y + 1, w - 2, h - 2)
    if self:isChecked() then
        render.setColor(self:getColorScheme("header"))
        render.drawRoundedBox(round, x + 3, y + 3, w - 6, h - 6)
    end
end
function Checkbox:getRounded()
    return UI._Skin.Checkbox.rounded
end
function Checkbox:setChecked(state)
    self._checked = state

    self:onChange(state)
end

function Checkbox:isChecked()
    return self._checked
end

function Checkbox:toggle()
    self:setChecked(not self:isChecked())
end

function Checkbox:onMousePressed(x, y, key, keyName)

    if key == MOUSE.MOUSE1 or key == MOUSE.MOUSE2 and not self._lock then
        self:setUsed(true)
        self:onUse(true)
    end
end

function Checkbox:onMouseReleased(x, y, key, keyName)
    if key == MOUSE.MOUSE1 or key == MOUSE.MOUSE2 and self:isUsed() then
        if key == MOUSE.MOUSE1 then
            self:onClick()
        elseif key == MOUSE.MOUSE2 then
            self:onRightClick()
        end

        self:setUsed(false)
        self:onUse(false)
        self:toggle()
    end
end

function Checkbox:onClick()
end
function Checkbox:onRightClick()
end
function Checkbox:onUse(bool)
end
function Checkbox:setAlign(xy)
    self.alignX = xy
    self.alignY = xy
end
function Checkbox:setAlignX(X)
    self.alignX = X
end
function Checkbox:setAlignY(Y)
    self.alignY = Y
end

function Checkbox:isUsed()
    return self.m_bUsed
end
function Checkbox:onChange(v)
end

return Checkbox
