---@name listview
---@author discord.gg/6Q5NnHQTrh // kekobka // STEAM_0:0:186583728
local E = require("./label.lua")
E:include(MIXIN)

local element = class("vListView", E)

function element:initialize(gui)
    E.initialize(self, gui)
    self._tabs = {}
    self._offsetH = 0
    self._taboffsetH = 0
    self._selected = nil
    self:dockPadding(0, 24, 0, 0)
    self.scroll = self.gui:add("bslider", self)
    self.scroll:setSize(24, 0)
    self.scroll:dock(RIGHT)
    self.scroll:setHorizontal()
    function self.scroll.onChange(scroll, value)
        self._offsetH = value
        self:invalidateLayout()
    end

end

function element:onMouseWheeled(x, y, key, keyName)
    if key == MOUSE.MWHEELUP then
        self._offsetH = self._offsetH - 1 / 24
    else
        self._offsetH = self._offsetH + 1 / 24
    end
    self.scroll._value = self._offsetH
    self:invalidateLayout()
end

function element:addColumn(column, position)
    -- :(
end

function element:onMousePressed(x, y, key, keyName)
    if key == MOUSE.MOUSE1 or key == MOUSE.MOUSE2 and not self._lock then
        local _, Y = self:getAbsolutePos()
        local offset = y - Y
        if offset < 24 then
            return
        end
        offset = math.max(math.floor(offset / 24), 1)
        local offsetf = self._offsetH * math.max(0, (self._taboffsetH - self:getH() + 48))
        local start = offset + math.max(math.floor(offsetf / 24 - 1), 0)
        local el = self._tabs[start]
        if not el then
            return
        end
        el:setUsed(true)
        self.__predselect = start

    end
end
function element:select(id)
    local el = self._tabs[id]

    if not el then
        return
    end
    if self._selected then
        if self._selected == el then
            return
        end
        self._selected:setEnabled(true)
        self._selected:setUsed(false)
    end
    self._selected = el
    self:onSelected(id, el:getText(), el)
    -- self.scroll:setValue(id / table.count(self._tabs))
    el:setEnabled(false)

end

function element:onMouseReleased(x, y, key, keyName)

    if key == MOUSE.MOUSE1 or key == MOUSE.MOUSE2 then
        if key == MOUSE.MOUSE1 then

            self:select(self.__predselect)
            self.__predselect = nil
            -- self:onClick()
        elseif key == MOUSE.MOUSE2 then
            -- self:onRightClick()
        end

    end
end

local dummy = function()
end
function element:addLine(id, text)
    local el = self.gui:add("button", self)
    self._tabs[id] = el
    el:setSize(self:getW() - 24, 24)
    el:setText(text)
    el._onPaint = dummy
    el._onMousePressed = dummy
    el._onMouseReleased = dummy
    el._onMouseWheeled = dummy
    self._taboffsetH = self._taboffsetH + 24

    -- el:setVisible(false)
    self:invalidateLayout()
end

function element:editLine(id, text)
    self._tabs[id]:setText(text)
end
function element:isValid(id)
    return self._tabs[id] ~= nil
end

function element:removeById(id)
    self._tabs[id]:remove()
    self._tabs[id] = nil
    self._taboffsetH = self._taboffsetH - 24
    self:invalidateLayout()
end
function element:clear(...)
    for id, tab in pairs(self._tabs) do
        tab:remove()
        self._tabs[id] = nil
    end
    self._taboffsetH = 0
    self:invalidateLayout()
end

function element:paint(x, y, w, h)
    self._hovered = false
    render.setColor(self:getColorFromScheme("bg"))
    render.drawRectFast(x, y, w, h)

    -- self.textmatrix:setTranslation(Vector(x + w / 2, y + 12))
    -- self.textmatrix:setScale(Vector(self._textW / 255 *2 ,self._textH / 255 * 2, 0))

    -- render.pushMatrix(self.textmatrix)

    render.setFont(self:getFont())
    render.setColor(self:getColorFromScheme("text"))
    render.drawSimpleText(x + w / 2, y + 12, self:getText(), self._align, self._align)

    -- render.popMatrix(self.textmatrix)
end

function element:performLayout(w, h)

    if not self.scroll then
        return
    end
    self.scroll:dock(RIGHT, true)
    self.scroll:invalidateLayout()
end

function element:postChildPaint(x, y, w, h)
    self._offsetH = math.clamp(self._offsetH or 0, 0, 1)

    local offset = self._offsetH * math.max(0, ((self._taboffsetH or 0) - h + 48))
    local start = math.max(math.floor(offset / 24), 1)
    local finish = math.floor(start + h / 24)
    local localoffset = 0
    render.enableScissorRect(x, y, x + w, y + h)
    for idx = start, finish do
        local el = self._tabs[idx]
        if not el then
            break
        end
        el:setPos(0, localoffset)
        localoffset = localoffset + 24

        local w, h = el:getSize()
        el.lastx, el.lasty = nil, nil
        el:paint(x, y + localoffset, w, h)

    end
    render.disableScissorRect()
end
-- STUB

function element:onSelected(id, text, button)
end

return element

