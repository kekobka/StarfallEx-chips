local Panel = class("VUI.Panel", Element)
function Panel:initialize(UI, b)
    Panel.super.initialize(self, UI, true)
    if not b then
        self:init()
    end
end
function Panel:paint(x, y, w, h)
    local round = self:getRounded()
    if not self._color then
        render.setColor(self:isHovered() and self:getColorScheme("bghover") or self:getColorScheme("bg"))
    else
        render.setColor(self._color)
    end
    render.drawRoundedBox(round, x, y, w, h)
end
function Panel:getRounded()
    return self.UI._Skin.Panel.rounded
end
function Panel:setColor(v)
    self._color = v
end
function Panel:getColor()
    return self._color
end
return Panel
