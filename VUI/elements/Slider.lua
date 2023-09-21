local Slider = class("VUI.Slider", Element)

accessorFunc(Slider, "m_bValue", "Value", 0.5)
accessorFunc(Slider, "m_bVertical", "Vertical", false)

function Slider:initialize(UI)
    Slider.super.initialize(self, UI)
    self:setSize(200, 8)
    self.m_bLerp = 0

end
function Slider:setVertical(b)

    if self.m_bVertical ~= b then
        self:setSize(self:getH(), self:getW())
    end
    self.m_bVertical = b
end
function Slider:paint(x, y, w, h)
    self.m_bLerp = math.clamp(self.m_bLerp + ((self:isHovered() or self:isUsed()) and 4 or -4) * timer.frametime() , 0, 1)
    if self.m_bVertical then
        local h = h - 10
        local y = y + 5
        render.setColor(self:getColorScheme("bghover"))
        render.drawRectFast(x + w / 2 - 1, y, 2, h)
        local clr = self:getColorScheme("header")
        render.setColor(clr)
        local v = x + w / 2
        local offset = h * self:getValue()
        render.drawRectFast(v - 1, y, 2, offset)
        render.setColor(clr * self.m_bLerp)
        render.drawFilledCircle(v, y + offset, 4)
    else
        local w = w - 10
        local x = x + 5
        render.setColor(self:getColorScheme("bghover"))
        render.drawRectFast(x, y + h / 2 - 1, w, 2)
        local clr = self:getColorScheme("header")
        render.setColor(clr)
        local v = y + h / 2
        local offset = w * self:getValue()
        render.drawRectFast(x, v - 1, offset, 2)
        render.setColor(clr * self.m_bLerp)
        render.drawFilledCircle(x + offset, v, 4)
    end
end

function Slider:onMousePressed(x, y, key, keyName)

    if key == MOUSE.MOUSE1 then
        self:setUsed(true)
        local px, py = self:getAbsolutePos()
        local w, h = self:getSize()
        local a = 0
        if self.m_bVertical then
            a = math.clamp(math.remap(y, py + 5, py + h - 5, 0, 1), 0, 1)
        else
            a = math.clamp(math.remap(x, px + 5, px + w - 5, 0, 1), 0, 1)
        end
        self:setValue(a)
        hook.add("inputReleased", "VUI.event_listener." .. table.address(self), function(key)
            local keyName = input.getKeyName(key)
            if key == MOUSE.MOUSE1 then
                self:onMouseReleased(x, y, key, keyName)
            end
        end)
        hook.add("VUI.mousemoved", "VUI.event_listener.mousemoved." .. table.address(self), function(x, y)
            local px, py = self:getAbsolutePos()
            local w, h = self:getSize()
            local a = 0
            if self.m_bVertical then
                a = math.clamp(math.remap(y, py + 5, py + h - 5, 0, 1), 0, 1)
            else
                a = math.clamp(math.remap(x, px + 5, px + w - 5, 0, 1), 0, 1)
            end
            self:setValue(a)
        end)
    end
end

function Slider:onMouseReleased(x, y, key, keyName)
    if key == MOUSE.MOUSE1 then
        self:setUsed(false)
        hook.remove("inputReleased", "VUI.event_listener." .. table.address(self))
        hook.remove("VUI.mousemoved", "VUI.event_listener.mousemoved." .. table.address(self))
    end
end

function Slider:setValue(v)

    if self.m_bValue ~= v then
        self.m_bValue = v
        self:onChange(self.m_bValue)
    end
end

function Slider:onMouseMoved(x, y)
    if self:getUsed() then

        local px, py = self:getAbsolutePos()
        local w, h = self:getSize()
        local a = 0
        if self.m_bVertical then
            a = math.clamp(math.remap(y, py + 5, py + h - 5, 0, 1), 0, 1)
        else
            a = math.clamp(math.remap(x, px + 5, px + w - 5, 0, 1), 0, 1)
        end
        if a ~= self:getValue() then
            self:setValue(a)
            self:onChange(self:getValue())
        end
    end
end

function Slider:onChange(newValue)
end
return Slider
