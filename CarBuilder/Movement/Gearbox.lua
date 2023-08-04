--@server

function table.map(tbl, action)
    local res = {}

    for idx, field in ipairs(tbl) do
        table.insert(res, action(field, idx))
    end

    return res
end

--@include ./Clutch.lua
local Clutch = require("./Clutch.lua") 
--@includedir ./Gearboxes/
local gearboxes = requiredir("./Gearboxes/")
local Gearboxes = {}

for path,Class in next, gearboxes do
    local type = path:getFileFromFilename():sub(1,-5)
    Class.static.type = type
    Gearboxes[type:lower()] = Class
end


local GearboxFabric = class("GearboxFabric")

function GearboxFabric:initialize(Transmission, axles, data)
    data.type = data.type:lower() or 'manual'
    self.data = data
    self.gearbox = Gearboxes[data.type:lower()](Transmission, axles, data)
    GearboxFabric.__index = self.gearbox
end
function GearboxFabric:link(engine)
    self.gearbox.clutch = Clutch(self.data.clutch, self.gearbox, engine)
    engine.clutch = self.gearbox.clutch
    engine.gearbox = self.gearbox
    
    self.engine = engine
    
end

function GearboxFabric:think()
    self.gearbox:think()
end
return GearboxFabric
