--@include libs/Task.txt
local Task = require("libs/Task.txt")
--@include libs/MeshBuilder.txt
local MeshBuilder = require("libs/MeshBuilder.txt")
local Chassis, Steering, Transmission, Camera
if SERVER then
    --@include ./Chassis.lua
    Chassis = require("./Chassis.lua")
    --@include ./Steering.lua
    Steering = require("./Steering.lua")

    --@include ./Movement/Transmission.lua
    Transmission = require("./Movement/Transmission.lua")
else
    --@include ./Camera.lua
    require("./Camera.lua")
    --@include ./Hud.lua
    require("./Hud.lua")
    --@include ./Sound.lua
    require("./Sound.lua")
end
local color_white = Color(255, 255, 255, 255)

local CarBuilder = class("CarBuilder")

CarBuilder.MeshBuilder = MeshBuilder

function CarBuilder:initialize(data)
    if CLIENT then
        SetSoundRedline(data.transmission.engine.maxRPM or 7000)
        return self
    end
    self.MeshBuilder = MeshBuilder(data.obj)
    local physics
    if data.body then
        local body = data.body
        local pos = body.pos or Vector()
        local ang = body.ang or Angle()
        local scale = body.scale or Vector(1)
        local parent = body.parent
        local relative = body.relative or chip()
        physics = self.MeshBuilder:phys(body.obj, pos, ang, scale, parent, relative)
    end
    self.mesh = {}
    for name, mesh in next, data.mesh do
        local pos = mesh.pos or Vector()
        local ang = mesh.ang or Angle()
        local scale = mesh.scale or Vector(1)
        local parent = mesh.parent or chip()
        local relative = mesh.relative or chip()
        local color = mesh.color or color_white
        local material = mesh.material or "models/debug/debugwhite"

        self.mesh[name] = {
            pos = pos,
            ang = ang,
            scale = scale,
            parent = parent,
            relative = relative,
            color = color,
            holo = self.MeshBuilder:build(name, pos, ang, scale, parent, relative, color, material)
        }
    end
    Task(function()
        self.body = await * physics()
        self.body:setMass(600)
        self.body:setInertia(Vector(0.2, 2, 2) * 600)
        self.body:setNoDraw(not DEBUG)
        self.Chassis = Chassis(self, self.body, data.chassis)
        local _ = await * self.Chassis:create()
        self.Steering = Steering(self, self.body, self.Chassis.axles, data.steering)
        self.Transmission = Transmission(self, data.transmission, self.Chassis.axles)
        hook.add("think", table.address(self), function()
            self:_think()
        end)
        self:onCreated()
        self.body:setFrozen(false)
    end)
    self.MeshBuilder:apply()
end

function CarBuilder:getSteerAngle()
    return self.Steering and self.Steering:getSteerAngle() or 0
end

function CarBuilder:getDriver()
    return self.Chassis and isValid(self.Chassis:getDriver()) and self.Chassis:getDriver() or nil
end

function CarBuilder:_think()
    local base = self.body
    if self.Transmission.Gearbox.clutch:getPress() == 1 or self.Transmission.Gearbox.ratio == 0 then
        local tiltForce = 2 * self.Transmission.Engine.torque * (-1 + self.Transmission.Engine.masterThrottle * 2)
        
        base:applyForceOffset(base:getUp() * tiltForce, base:getMassCenter() + base:getForward() * 39.37)
        base:applyForceOffset(-base:getUp() * tiltForce, base:getMassCenter() - base:getForward() * 39.37)
    end

    self.Transmission:think()

    net.start("CAR_SPEED")
    net.writeUInt(base:getVelocity():getLength()* 1.905 / 100000 * 3600, 12)
    net.send(nil, true)

    self:think()
    
end

--- эвент запускается сразу после инициализации подвески
function CarBuilder:onChassisCreated()
end

function CarBuilder:think()
end

function CarBuilder:onCreated()
end

return CarBuilder
