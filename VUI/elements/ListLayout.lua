local ListLayout = class("VUI.ListLayout", Element)

function ListLayout:initialize()
    ListLayout.super.initialize(self)
    self._list = {}
    self._lastFH = 0
    self:setSize(200, 200)
end

function ListLayout:paint(x, y, w, h)
    local round = self:getRounded()
    render.setColor(self:getColorScheme("bghover"))
    render.drawRoundedBox(round, x, y, w, h)
    render.setColor(self:getColorScheme("bg"))
    render.drawRoundedBox(round, x + 1, y + 1, w - 2, h - 2)
end
function ListLayout:getRounded()
    return UI._Skin.ListLayout.rounded
end
function ListLayout:getFullH()
    local w = 0
    for _, el in next, self._list do
        w = w + el:getH()
    end
    self._lastFH = w
    return w
end
function ListLayout:addLine(child)
    child:clearParent()
    self:addChild(child)
    local FH = self:getFullH()
    child:setPos(0, FH)
    if FH >= self:getH() then
        child:setVisible(false)
    end
    table.insert(self._list, child)
    self:_onNewLine(child)
end
function ListLayout:_onNewLine(child)
    self:onNewLine(child)
end
function ListLayout:onNewLine(child)

end
local max = math.max
function ListLayout:sizeToContents()
    local w, h = 0, 0
    for _, el in next, self._list do
        w = max(el:getW(), w)
        h = el:getH() + h
        el:setVisible(true)
    end
    self:setSize(w, h)
end

return ListLayout
