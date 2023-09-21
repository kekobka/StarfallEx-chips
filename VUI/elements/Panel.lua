local Panel = class("VUI.Panel", Element)
function Panel:initialize(UI)
    Panel.super.initialize(self, UI)

end
function Panel:paint(x, y, w, h)
    local round = self:getRounded()
    render.setColor(self:isHovered() and self:getColorScheme("bghover") or self:getColorScheme("bg"))
    render.drawRoundedBox(round, x, y, w, h)
end
function Panel:getRounded()
    return self.UI._Skin.Panel.rounded
end
return Panel
