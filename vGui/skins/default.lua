-- @name skin : Default
-- @author discord.gg/6Q5NnHQTrh // kekobka // STEAM_0:0:186583728
local SKIN = {}
if CLIENT then

    SKIN = {

        fonts = {
            main = {
                str = render.createFont("Roboto", 16, 400, true),
                size = 16
            },
            mainBold = {
                str = render.createFont("Roboto", 16, 700, true),
                size = 16
            },
            icons = {
                str = render.createFont("Segoe MDL2 Assets", 16, 400, true, true, false, false, false, true),
                size = 16
            },
            textentry = {
                str = render.createFont("Roboto", 16, 400, true),
                size = 16
            }
        },
        ColorScheme = {
            text = {
                Color(234, 231, 220),
                disabled = Color(100, 100, 100)
            },
            bg = {
                Color(47, 68, 84),
                used = Color(147, 168, 184),
                hover = Color(56, 81, 100),
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
    }
end

return SKIN

