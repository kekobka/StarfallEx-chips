-- :(


local E = require("./listview.lua")
E:include(MIXIN)

local PANEL = class("vMenu",E)

function PANEL:initialize(gui)
    -- E.initialize(self, gui)
    self.gui = gui
    self:setW(100)
    
end
function PANEL:paint(x,y,w,h)
end
function PANEL:AddSubMenu( strText, funcFunction )

	local pnl = self:add( "button" )
	pnl:setText( strText )
    pnl:setTall(18)
    pnl:setDrawBorder(false)

	local SubMenu = pnl.gui:add("menu")

	if ( funcFunction ) then SubMenu.onClick = funcFunction end
    pnl.onClick = function()
        local x,y = pnl:LocalToScreen()
        SubMenu:open(x + pnl:getW(), y,false,pnl)
    end
	return SubMenu, pnl

end
function PANEL:addOption( strText, funcFunction )

	local pnl = self:add( "button" )
	pnl:setText( strText )
    pnl:sizeToContents()
    pnl:setTall(18)
    
    pnl:setDrawBorder(false)
	if ( funcFunction ) then pnl.onClick = funcFunction end

	return pnl

end

function PANEL:addSpacer( strText, funcFunction )

	local pnl = self:add( "shape" )
	pnl.paint = function( self, x, y, w, h )
        render.setColor(Color(51,51,51,200))
		render.drawRectFast(x,y,w,h)
	end
    pnl:setW(self:getW())
	pnl:setH( 4 )

	return pnl

end

function PANEL:open( x, y, skipanimation, ownerpanel )
    self:setPos( x, y )
    if self:getParent() then
        self:getParent():moveToFront(self)
    end
	self:setSize( self:getWide(), 0 )
    self:setVisible(true)
    self:setEnabled(true)
    self:setMouseInputEnabled(true)
end

function PANEL:performLayout(w, h)

    local y = 0
    local temp = self._firstChild

    while temp do
        w = math.max(w,temp:getW())
        temp = temp._nextSibling
    end

    local temp = self._firstChild

    while temp do
		temp:setWide( w )
		temp:setPos( 0, y )
		temp:invalidateLayout()
		y = y + temp:getTall()
        temp = temp._nextSibling
    end

    self:setH(y)
    self:setW(w)
end

return PANEL
