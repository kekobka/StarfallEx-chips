


local E = require("./button.lua")
E:include(MIXIN)

local PANEL = class("vComboBox",E)
PANEL.static.accessorFunc( PANEL, "m_bDoSort", "SortItems", true )

function PANEL:initialize(gui)
    E.initialize(self, gui)
	self.DropButton = self:add("shape")
    
	function self.DropButton:paint( x, y, w, h ) 
        local H = self:getH()
        render.drawLine(x, y + H/4, x+w, y + H/4)
        render.drawLine(x + H/4, y + H/4*2, x+w, y + H/4*2)
        render.drawLine(x + H/2, y + H/4*3, x+w, y + H/4*3)
    end

	self.DropButton:setMouseInputEnabled( false )
	self.DropButton.ComboBox = self

	self:setH( 22 )
    
	self:Clear()
    self.DropButton:setSize( 16, 16 )
    self.DropButton:centerVertical()
    self.DropButton:alignRight( 4 )
    self:setAlign(0,1)

end

function PANEL:Clear()

	self:setText( "" )
	self.Choices = {}
	self.Data = {}
	self.ChoiceIcons = {}
	self.Spacers = {}
	self.selected = nil

	if ( self.Menu ) then
		self.Menu:remove()
		self.Menu = nil
	end

end

function PANEL:GetOptionText( id )

	return self.Choices[ id ]

end

function PANEL:GetOptionData( id )

	return self.Data[ id ]

end

function PANEL:GetOptionTextByData( data )

	for id, dat in pairs( self.Data ) do
		if ( dat == data ) then
			return self:GetOptionText( id )
		end
	end

	-- Try interpreting it as a number
	for id, dat in pairs( self.Data ) do
		if ( dat == tonumber( data ) ) then
			return self:GetOptionText( id )
		end
	end

	-- In case we fail
	return data

end

function PANEL:performLayout(w, h)
    if not self.DropButton then
        return
    end
	self.DropButton:setSize( 15, 15 )
	self.DropButton:alignRight( 4 )
	self.DropButton:centerVertical()

	-- Make sure the text color is updated
	-- DButton.PerformLayout( self, w, h )

end

function PANEL:chooseOption( value, index )

	if ( self.Menu ) then
		self.Menu:remove()
		self.Menu = nil
	end

	self:setText( value )

	-- This should really be the here, but it is too late now and convar changes are handled differently by different child elements
	--self:ConVarChanged( self.Data[ index ] )

	self.selected = index
	self:onSelect( index, value, self.Data[ index ] )

end

function PANEL:ChooseOptionID( index )

	local value = self:GetOptionText( index )
	self:ChooseOption( value, index )

end

function PANEL:GetSelectedID()

	return self.selected

end

function PANEL:GetSelected()

	if ( !self.selected ) then return end

	return self:GetOptionText( self.selected ), self:GetOptionData( self.selected )

end

function PANEL:onSelect( index, value, data )

	-- For override

end

function PANEL:onMenuOpened( menu )

	-- For override

end

function PANEL:addSpacer()

	self.Spacers[ #self.Choices ] = true

end

function PANEL:addChoice( value, data, select, icon )

	local i = table.insert( self.Choices, value )

	if ( data ) then
		self.Data[ i ] = data
	end
	
	if ( icon ) then
		self.ChoiceIcons[ i ] = icon
	end

	if ( select ) then
		self:chooseOption( value, i )
	end

	return i

end

function PANEL:isMenuOpen()

	return self.Menu && self.Menu:isVisible()

end

function PANEL:openMenu( pControlOpener )

	if ( pControlOpener && pControlOpener == self.TextEntry ) then
		return
	end

	-- Don't do anything if there aren't any options..
	if ( #self.Choices == 0 ) then return end

	-- If the menu still exists and hasn't been deleted
	-- then just close it and don't open a new one.
	if ( self.Menu ) then
		self.Menu:remove()
		self.Menu = nil
	end

	-- If we have a modal parent at some level, we gotta parent to that or our menu items are not gonna be selectable
	local parent = self
	while ( isValid( parent ) && !parent:IsModal() ) do
		parent = parent:GetParent()
	end
	if ( !isValid( parent ) ) then parent = self end

	self.Menu = self.gui:add("menu")

	if ( self:getSortItems() ) then
		local sorted = {}
		for k, v in pairs( self.Choices ) do
			local val = tostring( v ) 
			table.insert( sorted, { id = k, data = v, label = val } )
		end
		for k, v in pairs( sorted ) do
			local option = self.Menu:addOption( v.data, function() self:chooseOption( v.data, v.id ) end )
			if ( self.ChoiceIcons[ v.id ] ) then
				-- option:SetIcon( self.ChoiceIcons[ v.id ] )
			end
			if ( self.Spacers[ v.id ] ) then
				self.Menu:addSpacer()
			end
		end
	else
		for k, v in pairs( self.Choices ) do
			local option = self.Menu:addOption( v, function() self:chooseOption( v, k ) end )
			if ( self.ChoiceIcons[ k ] ) then
				option:SetIcon( self.ChoiceIcons[ k ] )
			end
			if ( self.Spacers[ k ] ) then
				self.Menu:addSpacer()
			end
		end
	end

	local x, y = self:LocalToScreen( 0, self:getTall() )

	self.Menu:open( x, y, false, self )

	self:onMenuOpened( self.Menu )

end

function PANEL:closeMenu()

	if ( self.Menu ) then
		self.Menu:remove()
        self.Menu = nil
	end

end

function PANEL:Think()

	self:CheckConVarChanges()

end

function PANEL:setValue( strValue )

	self:setText( strValue )

end

function PANEL:onClick()

	if ( self:isMenuOpen() ) then
		return self:closeMenu()
	end

	self:openMenu()

end

function PANEL:GenerateExample()

	self:addChoice( "Some Choice" )
	self:addSpacer()
    self:addChoice( "Some Choice2" )
    self:addChoice( "Some Choice3" )
    self:addChoice( "Some Choice4" )
    self:addSpacer()
    self:addSpacer()
    self:addChoice( "Some Choice5" )
    self:addChoice( "Some Choice5" )

	self:addChoice( "Another Choice", "myData" )
	self:addChoice( "Default Choice", "myData2", true )
	self:setWide( 150 )

end

return PANEL