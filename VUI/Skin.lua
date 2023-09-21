
local Skin = class("VUI.util.Skin")

function Skin:initialize(data)
    self.Main = data.Main
    self.Button = data.Button or self.Main
    self.Label = data.Label or self.Main
    self.Frame = data.Frame or self.Main
    self.Checkbox = data.Checkbox or self.Main
    self.Slider = data.Slider or self.Main
    self.ListLayout = data.ListLayout or self.Main
    self.ScrollPanel = data.ScrollPanel or self.Main
    self.Combobox = data.Combobox or self.Main
    self.Panel = data.Panel or self.Main
    self.TextEntry = data.TextEntry or self.Main
    
end



return Skin