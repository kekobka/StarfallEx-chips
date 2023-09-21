---@name gui example
---@author discord.gg/6Q5NnHQTrh // kekobka // STEAM_0:0:186583728
---@shared
--[[

            ██╗░░██╗███████╗██╗░░██╗░█████╗░██████╗░██╗░░██╗░█████╗░
            ██║░██╔╝██╔════╝██║░██╔╝██╔══██╗██╔══██╗██║░██╔╝██╔══██╗
            █████═╝░█████╗░░█████═╝░██║░░██║██████╦╝█████═╝░███████║
            ██╔═██╗░██╔══╝░░██╔═██╗░██║░░██║██╔══██╗██╔═██╗░██╔══██║
            ██║░╚██╗███████╗██║░╚██╗╚█████╔╝██████╦╝██║░╚██╗██║░░██║
            ╚═╝░░╚═╝╚══════╝╚═╝░░╚═╝░╚════╝░╚═════╝░╚═╝░░╚═╝╚═╝░░╚═╝

]] --
if player() ~= owner() then
    return
end

local function createDOCKCHECK(gui, main, res, resy)
    local menu = gui:add("tab", main)
    menu:setText("DOCK")

    local w, h = main:getSize()
    local mx, my, mw, mh = 5, 5, 5, 5
    local leftshape = gui:add("shape", menu)
    leftshape:setSize(w / 2, 0)
    leftshape:dock(LEFT)
    leftshape:setColor(Color(0, 0, 0, 0))
    local button = gui:add("button", leftshape)
    button:setText("FILL")
    button:setSize(100, 32)
    button:dock(FILL)

    local button = gui:add("button", leftshape)
    button:setText("LEFT")
    button:setSize(100, 32)
    button:dock(LEFT)

    local button = gui:add("button", leftshape)
    button:setText("RIGHT")
    button:setSize(100, 32)
    button:dock(RIGHT)

    local button = gui:add("button", leftshape)
    button:setText("TOP")
    button:setSize(100, 32)
    button:dock(TOP)

    local button = gui:add("button", leftshape)
    button:setText("BOTTOM")
    button:setSize(100, 32)
    button:dock(BOTTOM)

    local rightshape = gui:add("shape", menu)
    rightshape:setSize(w / 2, 0)
    rightshape:dock(LEFT)
    rightshape:setColor(Color(0, 0, 0, 0))
    local button = gui:add("button", rightshape)
    button:setText("FILL")
    button:dock(FILL)

    local button = gui:add("button", rightshape)
    button:setText("TOP")
    button:dock(TOP)

    local button = gui:add("button", rightshape)
    button:setText("BOTTOM")
    button:dock(BOTTOM)

    local button = gui:add("button", rightshape)
    button:setText("LEFT")
    button:dock(LEFT)

    local button = gui:add("button", rightshape)
    button:setText("RIGHT")
    button:dock(RIGHT)

    leftshape:toAllChild(function(child)
        child:dockMargin(mx, my, mw, mh)
    end)
    rightshape:toAllChild(function(child)
        child:dockMargin(mx, my, mw, mh)
    end)

end
local function createExample(gui, main, res, resy)
    local menu = gui:add("tab", main)

    menu:addAnimation("Example", 0.3, 50, 1, menu.anims.HACKERSTRING)

    local but2 = gui:add("button", menu)
    but2:setText("Button")
    but2:setSize(100, 32)

    function but2:onClick()
        local w, h = menu:getSize()
    end
    local progress = gui:add("progress", menu)
    progress:setPos(0, 128 - 16)
    local slider = gui:add("bslider", menu)
    slider:setPos(0, 32)
    function slider:onChange(a)
        progress:setValue(a)
    end
    local checkbox = gui:add("checkbox", menu)
    checkbox:setPos(0, 32 + 16)
    checkbox:setLabel("Checkbox")
    local radios = {}
    local slider = gui:add("slider", menu)
    slider:setPos(0, 64)
    local textentry = gui:add("textentry", menu)
    textentry:setPos(0, 64 + 16)

    local listview = gui:add("listview", menu)
    listview:setText("listview")
    listview:setSize(200, 252)
    listview:setPos(128, 8)
    for i = 1, 5 do
        listview:addLine(i, i)
    end

    local combobox = gui:add("combobox", menu)
    combobox:setText("combobox")
    combobox:setWide(200)
    combobox:setPos(350, 8)
    combobox:GenerateExample()
    function combobox:onSelect(index, value, data)
        print(index, value, data)
    end
    for i = 1, 6 do
        local radio = gui:add("radio", menu)
        radio:setPos(2, 199 + i * 19 - 33)

        radio.numb = i
        table.insert(radios, radio)
    end
    for _, radio in ipairs(radios) do
        function radio:onChange(state)
            print(self.numb, state)
            if not state then
                return
            end
            for _, radio in ipairs(radios) do
                if radio ~= self then
                    radio:setChecked(false)
                end
            end

        end
    end

end
if CLIENT then
    ---@include ./vgui.lua
    local vGui = require('./vgui.lua')

    local gui = vGui:new("hud")
    gui:setVisible(true)
    res, resy = gui:getResolution()

    local mainmenu = gui:add("panel")
    mainmenu:setTitle("example")
    mainmenu:setSize(res / 2, resy / 2)
    mainmenu:center()
    local mainmenu = gui:add("tabholder", mainmenu)
    mainmenu:dock(FILL)

    createExample(gui, mainmenu, res, resy)
    createDOCKCHECK(gui, mainmenu, res, resy)

end

