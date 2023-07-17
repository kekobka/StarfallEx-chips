-- @name base element
-- @author discord.gg/6Q5NnHQTrh -- kekobka -- STEAM_0:0:186583728
local element = class("vElement")

function element.static.accessorFunc(tbl, varName, name, defaultValue)
    tbl[varName] = defaultValue
    tbl["get" .. name] = function(self) return self[varName] end
    tbl["set" .. name] = function(self, value) self[varName] = value end
end
local function canProcess()
    return math.max(cpuTotalAverage(), cpuTotalUsed() / 4) < cpuMax() * 0.7
end
local function async(a)
    local G = crc(tostring(a))
    local workers = {}
    hook.add("think", "async." .. G, function()
        for Key, work in ipairs(workers) do
            if not canProcess() then break end
            try(work(Key))
        end
    end)
    return function(...)
        local args = {...}
        table.insert(workers, function(Key)
            return coroutine.wrap(function()
                a(unpack(args))
                table.remove(workers, Key)
            end)
        end)
    end
end
local ANIMATIONTHINK = async(function(f) return f() end)
element.static.accessorFunc(element, "_x", "X", 0)
element.static.accessorFunc(element, "_y", "Y", 0)
element.static.accessorFunc(element, "_w", "W", 0)
element.static.accessorFunc(element, "_h", "H", 0)

function element:initialize(gui)

    self._enabled = true
    self._visible = true
    self.gui = gui
    self._draggable = true
    self.matrix = Matrix()

    if self.getFonts then self.fonts = self:getFonts() end


    self._lock = nil
    self.m_bMouseEnabled = true
end

element._parent = nil
element._firstChild = nil
element._prevSibling = nil
element._nextSibling = nil

element._dockMargin = {0, 0, 0, 0}
element._dockPadding = {0, 0, 0, 0}

function element:AnimationThink(f) return ANIMATIONTHINK(f) end

function element:setSize(w, h)

    if type(w) == "number" then
        self:setW(w)
        self:setH(h)
    else
        self:setW(w[1])
        self:setH(w[2])
    end
    self:invalidateLayout()
end

function element:setWide(w)
    self:setW(w)
    self:invalidateLayout()
end

function element:setTall(h)
    self:setH(h)
    self:invalidateLayout()
end
element.getTall = element.getH
element.getWide = element.getW
function element:getSize() return self:getW(), self:getH() end

function element:setPos(x, y)

    if type(x) == "number" then
        self:setX(math.floor(x))
        self:setY(math.floor(y))
    else
        self:setX(x[1])
        self:setY(x[2])
    end
end

function element:getPos() return self:getX(), self:getY() end

function element:getBounds()
    return self:getX(), self:getY(), self:getX() + self:getW(),
           self:getY() + self:getH()
end

function element:dockPadding(q, w, e, r)
    self._dockPadding = {
        q or self._dockPadding[1], w or self._dockPadding[2],
        e or self._dockPadding[3], r or self._dockPadding[4]
    }
end
function element:dockMargin(a, s, d, f)
    self._dockMargin = {a, s, d, f}
    x, y = self:getPos()
    w, h = self:getSize()
    local x, y, w, h = x + a, y + s, w - d - a, h - f - s

    self:setPos(x, y)
    self:setSize(w, h)
    self:invalidateLayout()
end

function element:getAbsolutePos(x, y)
    x = x == nil and self:getX() or x + self:getX()
    y = y == nil and self:getY() or y + self:getY()

    if self:hasParent() then
        x, y = self:getParent():getAbsolutePos(x, y)
        local dx, dy = unpack(self:getParent()._dockPadding)
        x, y = x + dx, y + dy
    end

    return x, y
end
element.LocalToScreen = element.getAbsolutePos

function element:centerVertical(frac) 
    frac = frac or 0.5
    self:setY(self:getParent():getH() * frac - self:getH()/2)
end
function element:alignRight(offset) 
    offset = offset or 0.5
    self:setX(self:getParent():getW() - self:getW() - offset)
end
function element:setMouseInputEnabled(b) 
    self.m_bMouseEnabled = b
end

function element:setParent(parent) self._parent = parent end

function element:getParent() return self._parent end

function element:hasParent() return self:getParent() ~= nil end

function element:setEnabled(enabled) self._enabled = enabled end

function element:isEnabled() return self._enabled end

function element:setVisible(visible) self._visible = visible end

function element:isVisible() return self._visible end

function element:setUsed(v) self._used = v end

function element:isUsed() return self._used end

function element:setDraggable(draggable) self._draggable = draggable end

function element:isDraggable() return self._draggable end

function element:isHovered() return self._hovered end

function element:lock() self._lock = true end

function element:unlock() self._lock = false end
function element:isLocked() return self._lock end

function element:remove()
    self:setVisible(false)
    self:setEnabled(false)
    -- self:toAllChild(self.remove)
    if self:hasParent() then
        self:getParent():removeChild(self)
    end
    
end
function element:setSkin(skin)
    self:setColorScheme(skin.ColorScheme, true)
    self.fonts = skin.fonts
end

function element:addChild(child)

    child:setParent(self)

    if not self._firstChild then
        self._firstChild = child
    else
        local temp = self._firstChild

        while temp._nextSibling do temp = temp._nextSibling end

        temp._nextSibling = child
        child._prevSibling = temp
    end

end

function element:removeChild(child)

    if not child then return end

    child:setParent(nil)
    -- if self._firstChild == child then
    --     self._firstChild = nil
    -- else
        local prev = child._prevSibling or self
        local next = child._nextSibling
        -- if not prev then return end
        -- prev._nextSibling = next
        -- next._prevSibling = prev

    -- end

end

function element:dock(value, validate)

    if not self:hasParent() then return throw("no parent to docking") end

    local parent = self:getParent()
    local dx, dy, dw, dh = unpack(parent._dockPadding)
    local pw, ph = parent:getSize()
    local rw, rh = self:getSize()

    local FILL = parent._dockPadding_FILL
    local LEFT = parent._dockPadding_LEFT or 0
    local RIGHT = parent._dockPadding_RIGHT or 0
    local TOP = parent._dockPadding_TOP or 0
    local BOTTOM = parent._dockPadding_BOTTOM or 0

    self.docktype = value

    if value == 1 then -- FILL
        if FILL then return throw("element:dock(FILL) is used", 1, true) end
        local x = LEFT
        local y = TOP
        local w = pw - dx - dw - RIGHT + (validate and rw or 0)
        local h = ph - dy - dh - BOTTOM
        self:setPos(x, y)
        self:setSize(w, h)

        if not validate then parent._dockPadding_FILL = self end
    elseif value == 2 then -- LEFT

        local dw0, dh0 = self:getSize()

        local x = LEFT
        local y = TOP
        local w = dw0
        local h = ph - dy - dh - BOTTOM - TOP
        self:setPos(x, y)
        self:setSize(w, h)
        if not validate then parent._dockPadding_LEFT = LEFT + dw0 end
    elseif value == 3 then -- RIGHT

        local dw0, dh0 = self:getSize()

        local x = pw - dx - dw - dw0 - RIGHT + (validate and rw or 0)
        local y = TOP
        local w = dw0
        local h = ph - dy - dh - BOTTOM - TOP
        self:setPos(x, y)
        self:setSize(w, h)
        if not validate then parent._dockPadding_RIGHT = RIGHT + dw0 end
    elseif value == 4 then -- TOP

        local dw0, dh0 = self:getSize()

        local x = LEFT
        local y = TOP
        local w = pw - dx - dw - RIGHT - LEFT + (validate and rw or 0)
        local h = dh0
        self:setPos(x, y)
        self:setSize(w, h)
        if not validate then parent._dockPadding_TOP = TOP + dh0 end
    elseif value == 5 then -- BOTTOM

        local dw0, dh0 = self:getSize()

        local x = LEFT
        local y = ph - dy - dh - dh0 - BOTTOM
        local w = pw - dx - dw - RIGHT - LEFT + (validate and rw or 0)
        local h = dh0
        self:setPos(x, y)
        self:setSize(w, h)
        if not validate then parent._dockPadding_BOTTOM = BOTTOM + dh0 end
    end
    if not validate then self:invalidateDock(parent) end
    self:dockMargin(unpack(self._dockMargin))
end

function element:invalidateDock(parent)

    if not parent._dockPadding_FILL then return end
    local dx, dy, dw, dh = unpack(parent._dockPadding)
    local pw, ph = parent:getSize()

    local FILL = parent._dockPadding_FILL
    local LEFT = parent._dockPadding_LEFT or 0
    local RIGHT = parent._dockPadding_RIGHT or 0
    local TOP = parent._dockPadding_TOP or 0
    local BOTTOM = parent._dockPadding_BOTTOM or 0

    local x = LEFT
    local y = TOP
    local w = pw - dx - dw - RIGHT - LEFT
    local h = ph - dy - dh - BOTTOM - TOP

    parent._dockPadding_FILL:setPos(x, y)
    parent._dockPadding_FILL:setSize(w, h)
    parent._dockPadding_FILL:dockMargin(unpack(
                                            parent._dockPadding_FILL._dockMargin))
end
function element:cursorIntersect(x, y)

    local aX, aY = self:getAbsolutePos()

    if x >= aX and x < aX + self:getW() and y >= aY and y < aY + self:getH() then
        return true
    end

    return false
end
function element:center()
    local dw, dh = self:getParent():getSize()
    local w, h = self:getSize()
    local dx0, dy0, dw0, dh0 = unpack(self:getParent()._dockPadding)

    self:setPos(dw / 2 - w / 2 - (dw0 + dx0) / 2,
                dh / 2 - h / 2 - (dh0 + dy0) / 2)
end
function element:setColorScheme(scheme, overwrite)
    if overwrite or not self._colorScheme then
        self._colorScheme = scheme
    else
        self._colorScheme = table.merge(self._colorScheme, scheme)
    end
end

function element:getColorScheme() return self._colorScheme or {} end

function element:getFonts() return self.fonts end

function element:notChangeColorBorderOnHover() self._changeColorBorderOnHover = true  end

function element:getColorFromScheme(key)

    local scheme = self:getColorScheme()[key]
    local color
    if scheme then
        if not self:isEnabled() then
            color = scheme["disabled"] or scheme[1]
        elseif self:isUsed() then
            color = scheme["used"] or scheme[1]
        elseif self:isHovered() and not self._changeColorBorderOnHover then
            color = scheme["hover"] or scheme[1]
        else
            color = scheme[1]
        end
    end

    return color or Color(255, 0, 255)
end
function element:moveToFront(child)
    if child then
        local next = child._nextSibling
        local prev = child._prevSibling

        if prev then
            prev._nextSibling = next

            if next then next._prevSibling = prev end
        else
            return
        end

        child._nextSibling = self._firstChild
        self._firstChild._prevSibling = child
        child._prevSibling = nil
        self._firstChild = child
    end
end

function element:toAllChild(fn)
    local temp = self._firstChild

    while temp do
        local next = temp._nextSibling

        if fn(temp) then return temp end

        temp = next
    end

    return nil
end

function element:_postEvent(eventKey, ...)
    if eventKey == "THINK" then
        return self:_onThink(...)
    elseif eventKey == "PAINT" then
        return self:_onPaint(...)
    elseif eventKey == "MOUSE_PRESSED" then
        return self:_onMousePressed(...)
    elseif eventKey == "MOUSE_RELEASED" then
        return self:_onMouseReleased(...)
    elseif eventKey == "BUTTON_PRESSED" then
        return self:_onButtonPressed(...)
    elseif eventKey == "BUTTON_RELEASED" then
        return self:_onButtonReleased(...)
    elseif eventKey == "MOUSE_MOVED" then
        return self:_onMouseMoved(...)
    elseif eventKey == "MOUSE_WHEELED" then
        return self:_onMouseWheeled(...)
    end
end

function element:_postEventToAll(eventKey, ...)
    local temp = self._firstChild

    while temp do
        local next = temp._nextSibling

        if temp:_postEvent(eventKey, ...) then return temp end

        temp = next
    end

    return nil
end

function element:_postEventToAllReverse(eventKey, ...)
    local next = self._nextSibling

    if next then next:_postEventToAllReverse(eventKey, ...) end

    self:_postEvent(eventKey, ...)

    return nil
end

function element:_onPaint(dx, dy, dw, dh)
    if self:isVisible() then
        local x, y = self:getAbsolutePos()
        local w, h = self:getSize()

        render.enableScissorRect(x, y, x + w, y + h)
        self:paint(x, y, w, h)
        render.disableScissorRect()

        if self._firstChild then
            self._firstChild:_postEventToAllReverse("PAINT")
        end

        self:postChildPaint(x, y, w, h)
    end
end

function element:_onThink()
    if self:isEnabled() and self:isVisible() then
        self:think()

        if self._firstChild then
            self._firstChild:_postEventToAllReverse("THINK")
        end
    end
end

function element:_onMousePressed(x, y, key, keyName)

    if self:cursorIntersect(x, y) and self:isEnabled() and self:isVisible() and
        not self:isLocked() and self.m_bMouseEnabled then
        local element =
            self:_postEventToAll("MOUSE_PRESSED", x, y, key, keyName)

        if not element then
            self:onMousePressed(x, y, key, keyName)

            if self:hasParent() then
                self:getParent():moveToFront(self)
            end
        end

        return true
    else
        return false
    end
end

function element:_onMouseReleased(x, y, key, keyName)
    if self:cursorIntersect(x, y) and self:isEnabled() and self:isVisible() and
        not self:isLocked() and self.m_bMouseEnabled then
        local element = self:_postEventToAll("MOUSE_RELEASED", x, y, key,
                                             keyName)

        if not element then self:onMouseReleased(x, y, key, keyName) end

        return true
    else
        return false
    end
end
function element:_onMouseWheeled(x, y, key, keyName)
    if self:cursorIntersect(x, y) and self:isEnabled() and self:isVisible() and
        not self:isLocked() and self.m_bMouseEnabled then
        local element =
            self:_postEventToAll("MOUSE_WHEELED", x, y, key, keyName)

        if not element then self:onMouseWheeled(x, y, key, keyName) end

        return true
    else
        return false
    end
end

function element:_onMouseMoved(x, y)

    local element = self:_postEventToAll("MOUSE_MOVED", x, y)

    self:onMouseMoved(x, y)

    if self:cursorIntersect(x, y) then
        if self:isEnabled() then
            if not self:isHovered() then
                self._hovered = true

                self:onMouseEnter()
            end

        end

    else
        if self:isHovered() then
            self._hovered = false

            self:onMouseLeave()
        end
    end

    return false
end

function element:_onButtonPressed(key, keyName) end

function element:_onButtonReleased(key, keyName) end

function element:add(classname)
    return self.gui:add(classname, self)
end

-- STUB

function element:performLayout(w, h) end

function element:invalidateLayout() self:performLayout(self:getSize()) end

function element:think() end

function element:paint(x, y, w, h) end

function element:postChildPaint(x, y, w, h) end

function element:onMousePressed(x, y, key, keyName) end

function element:onMouseReleased(x, y, key, keyName) end

function element:onMouseMoved(x, y) end

function element:onMouseEnter() end

function element:onMouseLeave() end

function element:onButtonPressed(key, keyName) end

function element:onButtonReleased(key, keyName) end

function element:onMouseWheeled(x, y, key, keyName) end

return element

