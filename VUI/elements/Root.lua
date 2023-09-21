local Root = class("VUI.Root", Element)
function Root:_onRender(x,y,w,h)
    if self._firstChild then
        self._firstChild:_postEventToAllReverseRender(x,y,w,h)
    end
end
return Root
