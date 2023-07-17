# StarfallEX GUI

> TO DO
- [ ] multiscreen rendering 
- [ ] more elements

### Components
>- [GUI functions](#gui)
>- [Element](/docs/element.md)
>- [Label](/docs/label.md)
>- [Button](/docs/button.md)
>- [Checkbox](/docs/checkbox.md)
>- [Panel](/docs/panel.md)
>- and more
---

## Short example
```lua
--@name vGui easy example
--@client
--@include vgui/vgui.lua
local vGui = require('vgui/vgui.lua')

local gui = vGui:new("hud") --creating new thread gui
gui:setVisible(true) --set visible on initialize
local res,resy = gui:getResolution() --get resolution for next operations

--gui:add(classname, parent or nil, function(newpanel) end or nil)
local panel = gui:add("panel")
panel:setTitle("example")
panel:setSize(res/2,resy/2)
panel:center()

```
![example](https://i.imgur.com/aTYUATu.png)
## Adding buttons
```lua
--@name vGui easy example
--@client
--@include vgui/vgui.lua
local vGui = require('vgui/vgui.lua')

local gui = vGui:new("hud") --creating new thread gui
gui:setVisible(true) --set visible on initialize
local res,resy = gui:getResolution() --get resolution for next operations

local panel = gui:add("panel")
panel:setTitle("example")
panel:setSize(res/2,resy/2)
panel:center()

local button = gui:add("button",panel)
button:setText("FILL")
button:dock(FILL)
function button:onClick()
    print("clicked!")
end
```
---


## GUI
>- **void** vGui.**error(...)**
>- **void** vGui.**print(...)**
>- **void** vGui.**hint(** *string text* **)**
>- **void** vGui.**httpget**(*string* **url**, *function* **callbackSuccess**, **function** *or nil* **callbackFail**, **table** *or nil* **headers** )
>- **void** vGui.**register(** *string classname*, *table panelTable*, *string baseName = "panel"* **)** -- Registers a panel for later creation via gui:add().
>- **void** gui:**getCursor()** -- This is used internally - although you're able to use it you probably shouldn't.
>- **element** gui:**add(** *string classname*, *parent element or nil*, *function callback or nil* **)** -- creating new element
>- **element** gui:**create(** *string classname*, *parent element or nil*, *function callback or nil* **)** -- This is used internally - although you're able to use it you probably shouldn't.
>- **void** gui:**setSkin(** *string skin name* **)** -- set skin to all elements ( get skin from **./skins** )
