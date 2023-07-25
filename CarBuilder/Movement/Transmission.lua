--@server
--@include ./Engine.lua
local Engine = require("./Engine.lua")
--@include ./Gearbox.lua
local Gearbox = require("./Gearbox.lua")
local Transmission = class("Transmission")

function Transmission:initialize(car, data, axles)
    self.car = car

    self.maxRPM = data.maxRPM or 6000
    self.Engine = Engine(self, data.engine)
    self.Gearbox = Gearbox(self, axles, data.gearbox)
    self.Gearbox:link(self.Engine)
end


function Transmission:think()
    self.Gearbox:think()
    self.Engine:think()
    
end





return Transmission
