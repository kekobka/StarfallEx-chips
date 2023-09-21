local Frame = class("VUI.Frame", Element)

function Frame:initialize(UI)
    Frame.super.initialize(self, UI)
    self._draggable = true
    self.title = self:add("label")
    self.title:setText("Frame")
    self.title:setPos(12, 4)
    self.title:disable()

    self.closeButton = self:add("button")
    self.closeButton:setFont(UI.FONTS.icons)
    self.closeButton:setText(string.utf8char(0xE8BB))
    self.closeButton:setSize(24, 24)
    self.closeButton:setAlign(1)
    self.closeButton:setPos(500 - 28, 4)
    self.closeButton.onClick = function()
        self:close()
    end

    self.minmaxButton = self:add("button")
    self.minmaxButton:setFont(UI.FONTS.icons)
    self.minmaxButton:setText(string.utf8char(0xE921))
    self.minmaxButton:setSize(24, 24)
    self.minmaxButton:setAlign(1)
    self.minmaxButton:setPos(500 - 56, 4)
    self._maximized = true
    self.minmaxButton.onClick = function()
        self:minimax()
    end

    self:setSize(500, 500)
end
-- local gU = Material("vgui/gradient_up")
-- local gD = Material("vgui/gradient_down")
-- local gR = Material("vgui/gradient-r")
-- local gL = Material("vgui/gradient-l")
function Frame:paint(x, y, w, h)
    local round = self:getRounded()
    local maxi = not self._maximized
    if not maxi then
        render.setColor(self:getColorScheme("bg"))
        render.drawRoundedBox(round, x, y, w, h)

    end
    render.setColor(self:getColorScheme("header"))

    render.drawRoundedBoxEx(round, x, y, w, 32, true, true, maxi, maxi)
end

function Frame:getColorScheme(type)
    return UI._Skin.Frame[type]
end
function Frame:getRounded()
    return UI._Skin.Frame.rounded
end
function Frame:isDraggable()
    return self._draggable
end
function Frame:setDraggable(b)
    self._draggable = b
end
function Frame:setTitle(b)
    self.title:setText(b)
end

function Frame:close()
    self:setVisible(false)
    self:setEnabled(false)
    self:onClose()
end

function Frame:setSize(w, h)
    self:setW(w)
    self:setH(h)
    self:invalidateLayout()
end
function Frame:minimax()
    if self._maximized then
        self:minimize()
    else
        self:maximize()
    end
end
function Frame:minimize()
    self._minimaxH = self:getH()
    self.minmaxButton:disable()
    local address = table.address(self) .. "minimax"

    self._stensil = true
    self:sizeTo(self:getW(), 32, 3, 0, math.easeInOutSine, function()
        self.minmaxButton:setText(string.utf8char(0xE922))
        self.minmaxButton:enable()
        self._maximized = false
        self._stensil = false
        self:toAllChild(function(child)
            if child == self.title or child == self.minmaxButton or child == self.closeButton then
                return
            end
            child[address] = child:isVisible()
            child:setVisible(false)
        end)
    end)
end
function Frame:maximize()
    self.minmaxButton:disable()
    self._maximized = true
    self._stensil = true
    local address = table.address(self) .. "minimax"
    self:toAllChild(function(child)
        if child == self.title or child == self.minmaxButton or child == self.closeButton then
            return
        end
        child:setVisible(child[address])
    end)
    self:sizeTo(self:getW(), self._minimaxH, 3, 0, math.easeInOutSine, function()
        self.minmaxButton:setText(string.utf8char(0xE921))
        self._minimaxH = nil

        self._stensil = false
        self.minmaxButton:enable()
    end)
end

function Frame:onMousePressed(x, y, key, keyName)
    if key == MOUSE.MOUSE1 then
        local aX, aY = self:getAbsolutePos()
        if self:isDraggable() and y < aY + 32 then
            self._dragStartPos = {x - self:getX(), y - self:getY()}

            hook.add("VUI.mousemoved", "VUI.event_listener." .. table.address(self), function(x, y)
                self:onMouseMoved(x, y)
            end)
            hook.add("inputReleased", "VUI.event_listener." .. table.address(self), function(key)
                local keyName = input.getKeyName(key)
                if key == MOUSE.MOUSE1 then
                    self:onMouseReleased(x, y, key, keyName)
                end
            end)
        end
    end
end

function Frame:onMouseReleased(x, y, key, keyName)

    if key == MOUSE.MOUSE1 then
        if self:isDraggable() then
            self._dragStartPos = nil
            hook.remove("gui_mousemoved", "VUI.event_listener." .. table.address(self))
            hook.remove("inputReleased", "VUI.event_listener." .. table.address(self))
        end
    end
end

function Frame:onMouseMoved(x, y)
    if self._dragStartPos then
        local targetX, targetY = x - self._dragStartPos[1], y - self._dragStartPos[2]

        self:setPos(targetX, targetY)
        self:invalidateLayout()
    end
end

function Frame:performLayout(w, h)
    -- local dx, dy, dw, dh = unpack(self._dockPadding)
    -- self.minimizeButton:setPos(w - 52 - dx, 6 - dy)
    self.closeButton:setPos(w - 28, 4)
    self.minmaxButton:setPos(w - 56, 4)
    self.title:setPos(12, 6)
end
function Frame:GenerateExample()
    self:setSize(800,800)
    local butt = self:add("Button")
    butt:setY(32)
    local comboBox = self:add("ComboBox")
    comboBox:setY(32)
    comboBox:setX(100)

    comboBox:addLine(comboBox:add("button"))
    comboBox:addLine(comboBox:add("button"))
    comboBox:addLine(comboBox:add("button"))
    comboBox:addLine(comboBox:add("button"))
    comboBox:addLine(comboBox:add("slider"))

    comboBox:addLine(comboBox:add("button"))
    comboBox:addLine(comboBox:add("button"))
    comboBox:addLine(comboBox:add("button"))

    local panel = self:add("Panel")
    panel:setX(250)
    panel:setY(32)
    panel:setSize(300, 300)

    panel:add("button"):dock(LEFT):setText("LEFT")
    panel:add("button"):dock(RIGHT):setText("RIGHT")
    panel:add("button"):dock(BOTTOM):setText("BOTTOM")
    panel:add("button"):dock(TOP):setText("TOP")
    panel:add("button"):dock(FILL):setText("FILL")
    local panel = self:add("Panel")
    panel:setX(250)
    panel:setY(332)
    panel:setSize(300, 300)

    panel:add("button"):dock(BOTTOM):setText("BOTTOM")
    panel:add("button"):dock(TOP):setText("TOP")
    panel:add("button"):dock(LEFT):setText("LEFT")
    panel:add("button"):dock(RIGHT):setText("RIGHT")
    panel:add("button"):dock(FILL):setText("FILL")
    -- panel:add("button"):dock(FILL)
    butt:setY(32)
    butt.onClick = function()
        self.UI:GenerateExample()
    end
    local slider = self:add("Slider")
    slider:setY(40 + butt:getH())
    local label = self:add("Label")
    label:setY(32 + butt:getH())
    slider:setX(label:getW())
    function slider:onChange(value)
        label:setText(math.round(value, 2) * 100)
    end

    local checkbox = self:add("checkbox")
    checkbox:setY(label:getY() + label:getH())
    local ScrollPanel = self:add("ScrollPanel")
    ScrollPanel:setY(checkbox:getY() + checkbox:getH())
    local f = function(s)
        label:setText(s:getText())
    end
    for i = 1, 50 do
        local l
        if i % 2 == 0 then
            l = self:add("Label")
            l:setText("Label: " .. i)
        elseif i % 3 == 0 then
            l = self:add("slider")
        else
            l = self:add("button")
            l:setText("Label: " .. i)
        end

        l:setSize(200 - 11, 24)
        l.onClick = f
        ScrollPanel:addLine(l)
    end
    local TextEntry = self:add("TextEntry")
    TextEntry:setY(ScrollPanel:getY() + ScrollPanel:getH())
    TextEntry:setXOffset(5)
end
function Frame:onClose()

end
return Frame
