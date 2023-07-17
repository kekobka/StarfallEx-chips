Other components inherit these attributes
---
>- **bool** element:**isHovered()**
>- **bool** element:**isUsed()**
>- **element** element:**getParent()** 

>- **void** element:**setEnabled(** *bool enable* **)**
>- **bool** element:**isEnabled()**

>- **void** element:**setDraggable(** *bool enable* **)**
>- **bool** element:**isDraggable()**

>- **void** element:**setPos(** *number* **x,** *number* **y ) or setPos( Vector(x,y) )** -- set the position relative to the parent element
>- **number**, **number** element:**getPos()** -- get the position relative to the parent element
>- **void** element:**center()**

>- **void** element:**setSize(** *number* **width,** *number* **height ) or setPos( Vector(width, height) )** 
>- **number**, **number** element:**getSize()** 
>- **number**, **number**, **number**, **number** element:**getBounds()** -- get the bounds relative to the parent element

>- **void** element:**dockPadding(** *number* **x,** *number* **y,** *number* **w,** *number* **h )** -- [gmod wiki](https://wiki.facepunch.com/gmod/Panel:DockPadding)
>- **void** element:**dockMargin(** *number* **x,** *number* **y,** *number* **w,** *number* **h )** -- [gmod wiki](https://wiki.facepunch.com/gmod/Panel:DockMargin)

>- **void** element:**setVisible(Bool)** - Whether a component and it's children should be rendered
>- **bool** element:**isVisible()** - Whether a component and it's children should be rendered

>- **void** element:**lock()**
>- **void** element:**unlock()**
>- **bool** element:**isLocked()**
>- **void** element:**remove()**
>- **void** element:**setSkin(** *string skin name* **)**
>- **void** element:**dock(** *number DOCK* **)**

>- **void or element** element:**toAllChild(** *function* **)** --recursive function, any return stoped function


---
## STUB
Only for element creator

>- **void** element:**performLayout(** *number w*, *number h* **)**
>- **void** element:**think()**
>- **void** element:**paint(x, y, w, h)**
>- **void** element:**postChildPaint(x, y, w, h)**
>- **void** element:**onMousePressed(x, y, key, keyName)**
>- **void** element:**onMouseReleased(x, y, key, keyName)**
>- **void** element:**onMouseWheeled(x, y, key, keyName)**
>- **void** element:**onMouseMoved(x, y)**
>- **void** element:**onMouseEnter()**
>- **void** element:**onMouseLeave()**

---
# INTERNAL
This is used internally - although you're able to use it you probably shouldn't.
>- **void** element:**setX(** *number* **x )**<sup><sup> INTERNAL </sup></sup>
>- ****number**** element:**getX()**<sup><sup> INTERNAL </sup></sup>
>- **void** element:**setY(** *number* **y )**<sup><sup> INTERNAL </sup></sup>
>- **number** element:**getY()**<sup><sup> INTERNAL </sup></sup>
>- **void** element:**setW(** *number* **width )**<sup><sup> INTERNAL </sup></sup>
>- **number** element:**getW()**<sup><sup> INTERNAL </sup></sup>
>- **void** element:**setH(** *number* **height )** <sup><sup> INTERNAL </sup></sup>
>- **number** element:**getH()**<sup><sup> INTERNAL </sup></sup>
>- **number**, **number** element:**getAbsolutePos()** <sup><sup> INTERNAL </sup></sup>
>- **void** element:**setParent(** *element* )**<sup><sup> INTERNAL </sup></sup> 
>- **void** element:**setUsed(** *bool* **)**<sup><sup> INTERNAL </sup></sup> 
>- **void** element:**addChild(** *element* **)**<sup><sup> INTERNAL </sup></sup> 
>- **bool** element:**cursorIntersect(** *number x*, *number y* **)**<sup><sup> INTERNAL </sup></sup> 
>- **table** element:**getColorScheme()**<sup><sup> INTERNAL </sup></sup> 
>- **table** element:**getFonts()**<sup><sup> INTERNAL </sup></sup> 
>- **color** element:**getColorFromScheme(** *any key* **)**<sup><sup> INTERNAL </sup></sup> 
>- **void** element:**moveToFront(** *element or nil* **)**<sup><sup> INTERNAL </sup></sup> 
>- **any** element:**_postEvent(** *eventKey*, *args or nil* **)**<sup><sup> INTERNAL </sup></sup> 
>- **any** element:**_postEventToAll(** *eventKey*, *args or nil* **)**<sup><sup> INTERNAL </sup></sup> 
>- **void** element:**_postEventToAllReverse(** *eventKey*, *args or nil* **)**<sup><sup> INTERNAL </sup></sup> 
>- **void** element:**_onPaint()**<sup><sup> INTERNAL </sup></sup> 
>- **void** element:**_onThink()**<sup><sup> INTERNAL </sup></sup> 
>- **bool** element:**_onMousePressed(** *x*, *y*, *key*, *keyName* **)**<sup><sup> INTERNAL </sup></sup> 
>- **bool** element:**_onMouseReleased(** *x*, *y*, *key*, *keyName* **)**<sup><sup> INTERNAL </sup></sup> 
>- **bool** element:**_onMouseWheeled(** *x*, *y*, *key*, *keyName* **)**<sup><sup> INTERNAL </sup></sup> 
>- **bool** element:**_onMouseMoved(** *x*, *y* **)**<sup><sup> INTERNAL </sup></sup> 
>- **void** element:**invalidateLayout()**<sup><sup> INTERNAL </sup></sup> 




---