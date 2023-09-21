function accessorFunc(tbl, varName, name, defaultValue)
    tbl[varName] = defaultValue
    tbl["get" .. name] = function(self)
        return self[varName]
    end
    tbl["set" .. name] = function(self, value)
        self[varName] = value
    end
end
_G.EVENT = {
    THINK = 1,
    MOUSE_PRESSED = 2,
    MOUSE_RELEASED = 3,
    BUTTON_PRESSED = 4,
    BUTTON_RELEASED = 5,
    MOUSE_MOVED = 6,
    MOUSE_WHEELED = 7
}
_G.FILL = 1
_G.LEFT = 2
_G.RIGHT = 3
_G.TOP = 4
_G.BOTTOM = 5