---@name label
---@author discord.gg/6Q5NnHQTrh // kekobka // STEAM_0:0:186583728
local E = require("./element.lua")

local element = class("vLabel", E)

local StringAnimaizer = class("StringAnimaizer")

StringAnimaizer.HACKERSTRING = function(i, l, t)
    local ret = string.explode("", t)
    for j = i, l do
        ret[j] = string.utf8char(math.random(200, 500))
    end
    return table.concat(ret)
end

StringAnimaizer.HACKERSTRINGRANDOM = function(i, l, t)
    local ret = string.explode("", t)
    for j = i, l do
        ret[math.random(1, #ret)] = string.utf8char(math.random(200, 500))
    end
    return table.concat(ret)
end

function StringAnimaizer:initialize(target, speed, rate, timeout, fn)

    function self:restart(newstr)
        if newstr then
            self.target = newstr
            self.length = newstr:len()
        end
        local i = 1
        self.co = coroutine.create(function()
            while true do
                self.draw = fn(math.floor(i) + 1, self.length, self.target)
                coroutine.wait(rate / 1000)
                if i >= self.length then
                    coroutine.wait(timeout)
                end
                i = (i % self.length) + (self.length * speed) / 10
            end
        end)
    end
    self:restart(target)
end

function StringAnimaizer:get()
    coroutine.resume(self.co)
    return self.draw
end

function element:initialize(gui)
    E.initialize(self, gui)

    self.anims = StringAnimaizer
    self._text = ""
    self._textWidth = 0
    self._textHeight = 0
    self._fontSize = 16
    self.textmatrix = Matrix()
    self.wmult = 1
    self.hmult = 1
    self._align = 1
    self._aligny = 1
    self:setFont(self.gui.skin.fonts["main"])
    self:setText("Label")
    local w, h = self:getTextSize()
    self:setSize(w / self._fontSize * 16, h / self._fontSize * 16)
    self._textW = w / 64
    self._textH = h / 32

end

function element:paint(x, y, w, h)

    -- self.textmatrix:setTranslation(Vector(x, y))
    -- self.textmatrix:setScale(Vector(self._textW / 255 * 2,
    --                                 self._textH / 255 * 2, 0))

    -- render.pushMatrix(self.textmatrix)

    render.setFont(self:getFont())
    render.setColor(self:getColorFromScheme("text"))
    render.drawSimpleText(x, y, self:getText(), self._align, self._aligny)

    -- render.popMatrix(self.textmatrix)
end

function element:setFont(font)
    self._font = font.str
    self._fontSize = font.size
    render.setFont(self._font)

    self._textWidth, self._textHeight = render.getTextSize(self:getText())
    return self
end

function element:setText(text)
    self._text = tostring(text)

    if self:getFont() then
        render.setFont(self:getFont())

        self._textWidth, self._textHeight = render.getTextSize(text)
    else
        render.setFont(render.getDefaultFont())
        self._textWidth, self._textHeight = render.getTextSize(text)
    end
    return self
end

function element:getText()
    return self._text
end

function element:getFont()
    return self._font
end
function element:setAlign(x, y)
    self._align = x
    self._aligny = y and y or x
end

function element:getTextSize()
    return self._textWidth, self._textHeight
end
function element:addAnimation(target, speed, rate, timeout, fn)
    self._anim = StringAnimaizer:new(target, speed, rate, timeout, fn)
    self:setText(target)
    self:sizeToContents()
    hook.add("think", table.address(self._anim), function()
        self:setText(self._anim:get())
    end)
    return self
end

function element:setPos(x, y)

    if type(x) == "number" then
        self:setX(x)
        self:setY(y)
    else
        self:setX(x[1])
        self:setY(x[2])
    end

end

function element:scale(wmult, hmult)

    local w, h = self:getSize()

    local w = w * wmult
    local h = h * hmult
    self.wmult = wmult
    self.hmult = hmult

    self:setW(w)
    self:setH(h)

end

function element:setScale(...)
    self:scale(...)
end
function element:getAnimators()
    return self.anims
end

function element:setTextSize(w, h)

    if type(w) == "number" then
        self._textW = w
        self._textH = h
    else
        self._textW = w[1]
        self._textH = w[2]
    end
end
function element:sizeToContents()
    local s, d = self:getTextSize()

    self:setSize(s / self._textW, d / self._textH)
end

return element

