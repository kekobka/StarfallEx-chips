local Element = class("VUI.Element")
accessorFunc(Element, "_X", "X", 0)
accessorFunc(Element, "_Y", "Y", 0)
accessorFunc(Element, "_W", "W", 0)
accessorFunc(Element, "_H", "H", 0)

accessorFunc(Element, "m_bUsed", "Used", false)
accessorFunc(Element, "m_bEnabled", "Enabled", true)

function Element:initialize(UI)
    self.UI = UI
    self._visible = true
    self._enabled = true
    self.m_bDockPadding = {0, 0, 0, 0}
    self.m_bDockMargin = {0, 0, 0, 0}
end

Element._parent = nil
Element._firstChild = nil
Element._prevSibling = nil
Element._nextSibling = nil
local floor = math.floor
function Element:setX(x)
    self._X = floor(x)
end
function Element:setY(y)
    self._Y = floor(y)
end
function Element:setW(w)
    self._W = floor(w)
end
function Element:setH(h)
    self._H = floor(h)
end
function Element:getPos()
    return self:getX(), self:getY()
end
function Element:setPos(x, y)
    self:setX(x)
    self:setY(y)
end
function Element:setSize(w, h)
    self:setW(w)
    self:setH(h)
end
function Element:getSize(w, h)
    return self:getW(w), self:getH(h)
end
function Element:add(name)
    if not name then
        return throw("is not element")
    end
    assert(istable(UI._elements[name:lower()]), name .. " is not element")
    local el = UI._elements[name:lower()](self.UI)
    el.UI = self.UI
    self:addChild(el)

    return el
end
function Element:getAbsolutePos(x, y)
    x = x == nil and self:getX() or x + self:getX()
    y = y == nil and self:getY() or y + self:getY()

    if self:hasParent() then
        x, y = self:getParent():getAbsolutePos(x, y)
        -- local dx, dy = unpack(self:getParent()._dockPadding)
        -- x, y = x + dx, y + dy
    end
    return x, y
end
function Element:cursorIntersect(x, y)

    local aX, aY = self:getAbsolutePos()

    if x >= aX and x < aX + self:getW() and y >= aY and y < aY + self:getH() then
        return true
    end

    return false
end
function Element:cursorIntersectParent(x, y)

    local aX, aY = self:getPos()

    if x >= aX and x <= aX + self:getW() and y >= aY and y <= aY + self:getH() then
        return true
    end

    return false
end
function Element:setParent(parent)
    self._parent = parent
end

function Element:getParent()
    return self._parent
end

function Element:isHovered()
    return self._hovered
end
function Element:hasParent()
    return self:getParent() ~= nil
end
function Element:setVisible(visible)
    self._visible = visible
end

function Element:isEnabled()
    return self.m_bEnabled == true
end
function Element:disable()
    self.m_bEnabled = false
end
function Element:enable()
    self.m_bEnabled = true
end
function Element:isVisible()
    return self._visible
end
function Element:isUsed()
    return self.m_bUsed
end

function Element:dockPadding(x, y, w, h)
    self.m_bDockPadding = {x or 0, y or 0, w or 0, h or 0}
end
function Element:dockMargin(x, y, w, h)
    self.m_bDockMargin = {x or 0, y or 0, w or 0, h or 0}
end
function Element:dock(value)
    if not self:hasParent() then
        return throw("no parent to docking")
    end
    self.m_bDock = value
    local parent = self:getParent()
    local Px, Py, Pw, Ph = unpack(parent.m_bDockPadding)
    local Mx, My, Mw, Mh = unpack(self.m_bDockMargin)

    local pw, ph = parent:getSize()
    -- local sw, sh = self:getSize()

    local _FILL = parent._dockPadding_FILL
    local _LEFT = parent._dockPadding_LEFT or 0
    local _RIGHT = parent._dockPadding_RIGHT or 0
    local _TOP = parent._dockPadding_TOP or 0
    local _BOTTOM = parent._dockPadding_BOTTOM or 0
    if value == FILL then
        local x = _LEFT + Mx + Px
        local y = _TOP + My + Py
        local w = pw - Px - Pw - _RIGHT - Mx - Mw - _LEFT
        local h = ph - Py - Ph - _BOTTOM - My - Mh - _TOP
        self:setPos(x, y)
        self:setSize(w, h)
    elseif value == LEFT then

        local w0, h0 = self:getSize()

        local x = _LEFT + Mx + Px
        local y = _TOP + My + Py
        local w = w0 - Mw
        local h = ph - Py - Ph - _BOTTOM - _TOP - My - Mh
        self:setPos(x, y)
        self:setSize(w, h)
        parent._dockPadding_LEFT = _LEFT + w0
    elseif value == RIGHT then
        local w0, h0 = self:getSize()

        local x = pw - Pw - w0 - _RIGHT
        local y = _TOP + Mx + Px
        local w = w0 - Mw
        local h = ph - Py - Ph - _BOTTOM - _TOP - My - Mh
        self:setPos(x, y)
        self:setSize(w, h)
        parent._dockPadding_RIGHT = _RIGHT + w0
    elseif value == TOP then
        local w0, h0 = self:getSize()

        local x = _LEFT + Mx + Px
        local y = _TOP + My + Py
        local w = pw - Px - Pw - _RIGHT - _LEFT - Mx - Mw
        local h = h0 - Mh
        self:setPos(x, y)
        self:setSize(w, h)
        parent._dockPadding_TOP = _TOP + h0
    elseif value == BOTTOM then

        local w0, h0 = self:getSize()

        local x = _LEFT + Mx + Px
        local y = ph - Ph - h0 - _BOTTOM
        local w = pw - Px - Pw - _RIGHT - _LEFT - Mx - Mw
        local h = h0 - Mh
        self:setPos(x, y)
        self:setSize(w, h)
        parent._dockPadding_BOTTOM = _BOTTOM + h0
    end
    return self
end
function Element:addChild(child)

    child:setParent(self)

    if not self._firstChild then
        self._firstChild = child
    else
        local temp = self._firstChild

        while temp._nextSibling do
            temp = temp._nextSibling
        end

        temp._nextSibling = child
        child._prevSibling = temp
    end

end
function Element:removeChild(child)

    if not child then
        return
    end

    local prev = child._prevSibling
    local next = child._nextSibling
    if not prev then
        self._firstChild = nil
    else
        prev._nextSibling = next
        if next then
            next._prevSibling = prev
        end
    end
    child._nextSibling = nil
    child._prevSibling = nil
    child:setParent(nil)
end
function Element:clearParent()

    local parent = self:getParent()
    if not parent then
        return
    end
    parent:removeChild(self)
end

function Element:moveToFront(child)
    if child then
        local next = child._nextSibling
        local prev = child._prevSibling

        if prev then
            prev._nextSibling = next

            if next then
                next._prevSibling = prev
            end
        else
            return
        end
        if self._firstChild then
            child._nextSibling = self._firstChild
            self._firstChild._prevSibling = child
            child._prevSibling = nil
            self._firstChild = child
        end
    end
end
function Element:toAllChild(fn)
    local temp = self._firstChild

    while temp do
        local next = temp._nextSibling

        if fn(temp) then
            return temp
        end

        temp = next
    end

    return nil
end

function Element:_postEvent(eventKey, ...)
    if eventKey == EVENT.THINK then
        return self:_onThink(...)
    elseif eventKey == EVENT.MOUSE_PRESSED then
        return self:_onMousePressed(...)
    elseif eventKey == EVENT.MOUSE_RELEASED then
        return self:_onMouseReleased(...)
    elseif eventKey == EVENT.BUTTON_PRESSED then
        return self:_onButtonPressed(...)
    elseif eventKey == EVENT.BUTTON_RELEASED then
        return self:_onButtonReleased(...)
    elseif eventKey == EVENT.MOUSE_MOVED then
        return self:_onMouseMoved(...)
    elseif eventKey == EVENT.MOUSE_WHEELED then
        return self:_onMouseWheeled(...)
    end
end

function Element:_postEventToAll(eventKey, ...)
    local temp = self._firstChild

    while temp do
        local next = temp._nextSibling

        if temp:_postEvent(eventKey, ...) then
            return temp
        end

        temp = next
    end

    return nil
end
function Element:_postEventToAllReverseRender(x, y, w, h)
    local next = self._nextSibling

    if next then
        next:_postEventToAllReverseRender(x, y, w, h)
    end

    self:_onRender(x, y, w, h)

    return nil
end
local max, min = math.max, math.min
function Element:_onRender(X, Y, W, H)
    if not self:isVisible() then
        return
    end

    local x, y = self:getAbsolutePos()
    local w, h = self:getSize()
    local dx, dy, dw, dh = max(x, X), max(y, Y), min(x + w, W), min(y + h, H)
    render.enableScissorRect(dx, dy, dw, dh)
    self:paint(x, y, w, h)
    render.disableScissorRect()
    if self._firstChild then
        if self._stensil then
            self._firstChild:_postEventToAllReverseRender(x, y, x + w, y + h)
        else
            self._firstChild:_postEventToAllReverseRender(dx, dy, dw, dh)
        end
    end
    self:postChildPaint(x, y, w, h)

end
function Element:_onMousePressed(x, y, key, keyName)

    if self:cursorIntersect(x, y) and self:isVisible() and self:isEnabled() then
        local element = self:_postEventToAll(EVENT.MOUSE_PRESSED, x, y, key, keyName)

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
function Element:getColorScheme(type)
    return UI._Skin.Main[type]
end
function Element:_onMouseReleased(x, y, key, keyName)
    if self:cursorIntersect(x, y) and self:isVisible() and self:isEnabled() then
        local element = self:_postEventToAll(EVENT.MOUSE_RELEASED, x, y, key, keyName)

        if not element then
            self:onMouseReleased(x, y, key, keyName)
        end

        return true
    else
        return false
    end
end
function Element:_onButtonPressed(key, keyName)
end

function Element:_onButtonReleased(key, keyName)
end

function Element:_onMouseWheeled(x, y, key, keyName)
    if self:cursorIntersect(x, y) and self:isVisible() then
        local element = self:_postEventToAll(EVENT.MOUSE_WHEELED, x, y, key, keyName)

        if not element then
            self:onMouseWheeled(x, y, key, keyName)
        end

        return true
    else
        return false
    end
end

function Element:_onMouseMoved(x, y)

    if self:isEnabled() and self:isVisible() then
        if self:cursorIntersect(x, y) then
            self:onMouseMoved(x, y)

            if not self:isHovered() then
                self._hovered = true

                self:onMouseEnter()
            end

        else
            if self:isHovered() then
                self._hovered = false

                self:onMouseLeave()
            end

        end
    end
    self:_postEventToAll(EVENT.MOUSE_MOVED, x, y)
    return false
end

function Element:_onThink()
end
function Element:think()
end

function Element:paint(x, y, w, h)
end

function Element:postChildPaint(x, y, w, h)
end

function Element:onMousePressed(x, y, key, keyName)
end

function Element:onMouseReleased(x, y, key, keyName)
end

function Element:onMouseMoved(x, y)
end

function Element:onMouseEnter()
end

function Element:onMouseLeave()
end

function Element:onButtonPressed(key, keyName)
end

function Element:onButtonReleased(key, keyName)
end

function Element:onMouseWheeled(x, y, key, keyName)
end

function Element:performLayout(w, h)
end

function Element:invalidateLayout()
    self:performLayout(self:getSize())
end
local remap = math.remap
local dummy = function(x)
    return x
end
function Element:sizeTo(sizeW, sizeH, speed, delay, ease, callback)
    ease = ease or dummy
    local startW, startH = self:getSize()
    UI.newAnimation(speed, delay, function(progress)

        local w = remap(ease(progress), 0, 1, startW, sizeW)
        local h = remap(ease(progress), 0, 1, startH, sizeH)
        self:setSize(w, h)

    end, callback)
end

return Element
