# Panel

> [BaseClass](./element.md)

>- **void** Panel:**setTitle(** string *text* **)**
>- **string** Panel:**getTitle()**

>- **void** Panel:**close()**
>- **void** Panel:**open()**

>- **void** Panel:**minimizeMaximize()**
>- **void** Panel:**setMinimizable(** bool *state* **)**
>- **bool** Panel:**isMinimizable()** -- can minimize?
>- **bool** Panel:**isMinimized()**

>- **void** Panel:**setCloseable(** bool *state* **)**
>- **bool** Panel:**isCloseable()**
# STUB

>- **void** Panel:**onClose()**
>- **void** Panel:**onOpen()**

# INTERNAL
This is used internally - although you're able to use it you probably shouldn't.


>- **void** Panel:**setMinimized(** bool *state* **)**<sup><sup> INTERNAL </sup></sup> 
>- **void** Panel:**addTab()**<sup><sup> INTERNAL </sup></sup> 
>- **void** Panel:**updateTabs()**<sup><sup> INTERNAL </sup></sup> 
>- **void** Panel:**minimizeForced()**<sup><sup> INTERNAL </sup></sup> 
>- **void** Panel:**minimize()**
>- **void** Panel:**maximize()**
>- [Panel.title](./label.md)
>- [Panel.minimizeButton](./button.md)
>- [Panel.closeButton](./button.md)