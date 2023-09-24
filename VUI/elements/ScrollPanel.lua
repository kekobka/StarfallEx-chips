local ListLayout = require("./ListLayout.lua")

local ScrollPanel = class("VUI.ScrollPanel", ListLayout)

local remap, max, clamp = math.remap, math.max, math.clamp
function ScrollPanel:initialize(UI, b)
    ListLayout.initialize(self, UI, true)
    self.m_bSlider = self:add("Slider")
    self.m_bSlider:setVertical(true)
    self.m_bSlider:setPos(200 - self.m_bSlider:getW(), 0)

    self._list = {}
    self._listpos = 0
    self:setSize(200, 200)
    self.m_bSlider:setValue(0)
    self.m_bSlider.onChange = function(_, value)
        self:onScroll(value)
    end
    self.m_bSlider.onMouseWheeled = function(_, x, y, key, keyName)
        local v = self.m_bSlider:getValue()
        if key == MOUSE.MWHEELUP then
            v = v - 1 / self._lastFH * 80
        else
            v = v + 1 / self._lastFH * 80
        end
        self.m_bSlider:setValue(clamp(v, 0, 1))
    end
    self._onUseDumee = function(child, b, x, y, key, keyName)
        if b then
            self:onMousePressed(x, y, key, keyName, child)
        end
    end
    self._onScrollDumee = function(child, x, y, key, keyName)

        self:onMouseWheeled(x, y, key, keyName, child)

    end
    if not b then
        self:init()
    end
end
function ScrollPanel:getRounded()
    return UI._Skin.ScrollPanel.rounded
end
function ScrollPanel:onMousePressed(x, y, key, keyName, child)

    if key == MOUSE.MOUSE1 then
        local startY = y + self._listpos * self._lastFH
        hook.add("VUI.mousemoved", "VUI.event_listener." .. table.address(self), function(x, y)

            self.m_bSlider:setValue(clamp(remap(startY - y, 0, self._lastFH, 0, 1), 0, 1))
            if child then
                child:setUsed(false)
            end
        end)
        hook.add("inputReleased", "VUI.event_listener." .. table.address(self), function(key)
            if key == MOUSE.MOUSE1 then
                hook.remove("VUI.mousemoved", "VUI.event_listener." .. table.address(self))
                hook.remove("inputReleased", "VUI.event_listener." .. table.address(self))
            end
        end)
    end
end

function ScrollPanel:_onNewLine(child)
    child._onUse = self._onUseDumee
    child.onMouseWheeled = self._onScrollDumee
    self:onNewLine(child)
end
function ScrollPanel:onMouseWheeled(x, y, key, keyName)
    local v = self.m_bSlider:getValue()
    if key == MOUSE.MWHEELUP then
        v = v - 1 / self._lastFH * 30
    else
        v = v + 1 / self._lastFH * 30
    end
    self.m_bSlider:setValue(clamp(v, 0, 1))
end

function ScrollPanel:onScroll(value)

    local w = 0
    for _, el in next, self._list do
        local Y = w - value * max((self._lastFH - self:getH() + el:getH() ), 0)
        el:setY(Y + el.m_bDockMargin[2])
        local H = el:getH() + el.m_bDockMargin[2] + el.m_bDockMargin[4]
        if Y >= self:getH() or 0 > Y + H then
            el:setVisible(false)
        else
            el:setVisible(true)
        end
        -- if Y >= self:getH() then
        --     break
        -- end
        w = w + H

    end
    self._listpos = value
    -- self._lastFH = w
end

function ScrollPanel:setSize(w, h)
    self:setW(w)
    self:setH(h)
    self:invalidateLayout()
end
function ScrollPanel:performLayout(w, h)
    if not self.m_bSlider then
        return
    end
    self.m_bSlider:setPos(w - self.m_bSlider:getW() - 2, 1)
    self.m_bSlider:setH(h - 2)
end

return ScrollPanel
