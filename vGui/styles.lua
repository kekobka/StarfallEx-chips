-- @name styles
-- @author discord.gg/6Q5NnHQTrh // kekobka // STEAM_0:0:186583728
-- @shared
--[[

            ██╗░░██╗███████╗██╗░░██╗░█████╗░██████╗░██╗░░██╗░█████╗░
            ██║░██╔╝██╔════╝██║░██╔╝██╔══██╗██╔══██╗██║░██╔╝██╔══██╗
            █████═╝░█████╗░░█████═╝░██║░░██║██████╦╝█████═╝░███████║
            ██╔═██╗░██╔══╝░░██╔═██╗░██║░░██║██╔══██╗██╔═██╗░██╔══██║
            ██║░╚██╗███████╗██║░╚██╗╚█████╔╝██████╦╝██║░╚██╗██║░░██║
            ╚═╝░░╚═╝╚══════╝╚═╝░░╚═╝░╚════╝░╚═════╝░╚═╝░░╚═╝╚═╝░░╚═╝

]] --
STYLES = {
    label = {},
    panel = {},
    button = {},
    slider = {},
    checkbox = {},
    menu = {},
    shape = {},
    textentry = {}
}

local fonts = {}

local ColorScheme = {
    text = {Color(234, 231, 220), disabled = Color(100, 100, 100)},
    bg = {
        Color(47, 68, 84),
        used = Color(147, 168, 184),
        disabled = Color(32, 32, 32)
    },
    border = {
        Color(200, 255, 200, 10),
        hover = Color(200, 255, 200, 30),
        used = Color(200, 255, 200, 90),
        disabled = Color(32, 32, 32)
    },
    header = {Color(28, 51, 52)},
    mark = {
        Color(147, 168, 184),
        used = Color(147, 168, 184),
        disabled = Color(4, 6, 8)
    }
}

if CLIENT then
    local fonts = {
        main = {str = render.createFont("Roboto", 255, 400, true), size = 255},
        mainBold = {
            str = render.createFont("Roboto", 255, 700, true),
            size = 255
        },
        icons = {
            str = render.createFont("Segoe MDL2 Assets", 128, 400, true, false,
                                    false, false, false, true),
            size = 128
        },
        textentry = {
            str = render.createFont("Roboto", 16, 400, true),
            size = 16
        }
    }

    function STYLES.label:included(target) target:setColorScheme(ColorScheme) end

    function STYLES.panel:included(target) target:setColorScheme(ColorScheme) end

    function STYLES.button:included(target)

        target:setColorScheme(ColorScheme)

    end

    function STYLES.slider:included(target)

        target:setColorScheme(ColorScheme)

    end

    function STYLES.checkbox:included(target)

        target:setColorScheme(ColorScheme)

    end
    function STYLES.menu:included(target) target:setColorScheme(ColorScheme) end
    function STYLES.shape:included(target) target:setColorScheme(ColorScheme) end
    function STYLES.textentry:included(target)

        target:setColorScheme(ColorScheme)

    end

end

MIXIN = {}

accessorFunc(MIXIN, "_radius", "Radius", 0)

function MIXIN:included(target)
    self._roundTopLeftCorner = false
    self._roundTopRightCorner = false
    self._roundBottomLeftCorner = false
    self._roundBottomRightCorner = false
end

function MIXIN:setRoundedCorners(c1, c2, c3, c4)
    if c1 ~= nil and c2 ~= nil and c3 ~= nil and c4 ~= nil then
        self._roundTopLeftCorner = c1
        self._roundTopRightCorner = c2
        self._roundBottomRightCorner = c3
        self._roundBottomLeftCorner = c4
    elseif c1 ~= nil and c2 ~= nil and c3 ~= nil then
        self._roundTopLeftCorner = c1
        self._roundTopRightCorner = c2
        self._roundBottomRightCorner = c3
        self._roundBottomLeftCorner = c2
    elseif c1 ~= nil and c2 ~= nil then
        self._roundTopLeftCorner = c1
        self._roundTopRightCorner = c2
        self._roundBottomRightCorner = c1
        self._roundBottomLeftCorner = c2
    elseif c1 ~= nil then
        self._roundTopLeftCorner = c1
        self._roundTopRightCorner = c1
        self._roundBottomRightCorner = c1
        self._roundBottomLeftCorner = c1
    else
        self._roundTopLeftCorner = false
        self._roundTopRightCorner = false
        self._roundBottomRightCorner = false
        self._roundBottomLeftCorner = false
    end
end

function MIXIN:getRoundedCorners()
    return self._roundTopLeftCorner, self._roundTopRightCorner,
           self._roundBottomRightCorner, self._roundBottomLeftCorner
end

