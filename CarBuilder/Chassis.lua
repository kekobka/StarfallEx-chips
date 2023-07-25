--@server

local Chassis = class("Chassis")
local drivers = {}
local chairs = {}
function Chassis:initialize(car, body, data)
    self.data = data
    self.car = car
    self.axles = {}
    self.chairs = {}
    self.driverchair = {}
    self.base = body
    self.ropelength = data.RopeLength
    self.suspensiontravel = data.SuspensionTravel
    self.LimiterRopeLength = math.sqrt((self.suspensiontravel * 0.5) ^ 2 + self.suspensiontravel ^ 2)

end
Chassis.create = async* function(self)
    
    for id, axle in next, self.data.axles do
        local axle = await * self:createAxle(axle.pos, axle.ang, axle.steer)
        table.merge(axle, self.data.axles[id])
        table.insert(self.axles, axle)
    end

    for _, info in next, self.data.seats do
        local seat = await * self:createSeat(info.pos, info.ang)
        if info.driver then
            self.driverchair = seat
        end
        self.chairs[seat] = true
        chairs[seat] = true
    end

    self:_onCreated()
end



local function set_driver(ply, chair, role)

    if not chairs[chair] then return end
    local driver = role and ply 
    drivers[chair] = driver

    enableHud(ply, role and true or false)
end

hook.add("PlayerEnteredVehicle", "SetDriver", set_driver)
hook.add("PlayerLeaveVehicle", "SetDriver", set_driver)

function Chassis:getDriver()
    return isValid(self.driverchair) and self.driverchair:getDriver() or nil
end

Chassis.createWheel = async* function(self, pos, ang)
    while not prop.canSpawn() do
        sleep(250)
    end

    local wheel = prop.create(self.base:localToWorld(pos), ang, "models/sprops/trans/wheel_d/t_wheel25.mdl", true)
    constraint.nocollide(wheel, self.base)
    wheel:setMass(80)
    wheel:enableSphere(true)
    wheel:setInertia(Vector(6, 5, 6))
    wheel:getPhysicsObject():setMaterial("jeeptire")
    wheel:enableDrag(false)
    wheel:getPhysicsObject():enableMotion(false)
    while not prop.canSpawn() do
        sleep(250)
    end

    local plate = prop.create(wheel:localToWorld(Vector(0, 0, 25)), self.base:localToWorldAngles(Angle(0, 0, 0)), "models/hunter/plates/plate025.mdl", true)
    plate:enableMotion(true)
    plate:getPhysicsObject():sleep()
    plate:setNocollideAll(true)
    plate:setDrawShadow(false)
    plate:setNoDraw(not DEBUG)
    plate:setMass(0.1)
    plate:setParent(self.base)
    plate:enableDrag(false)

    return wheel, plate
end
Chassis.createSuspension = async* function(self, wheel, plate)

    constraint.elastic(1, wheel, self.base, 0, 0, Vector(0, 0, 0), self.base:worldToLocal(wheel:localToWorld(Vector(0, 0, self.suspensiontravel))), 42000, 1000, 1200, DEBUG and 1, false)

    constraint.rope(2, wheel, self.base, 0, 0, Vector(0, -4, 0), self.base:worldToLocal(wheel:localToWorld(Vector(self.ropelength, -self.ropelength, 0))), nil, 0, 0, DEBUG and 1, 0, true)
    constraint.rope(3, wheel, self.base, 0, 0, Vector(0, -4, 0), self.base:worldToLocal(wheel:localToWorld(Vector(-self.ropelength, -self.ropelength, 0))), nil, 0, 0, DEBUG and 1, 0, true)
    constraint.rope(4, wheel, self.base, 0, 0, Vector(0, -4, 0), self.base:worldToLocal(wheel:localToWorld(Vector(0, -self.suspensiontravel / 2 - 4, 0))), self.LimiterRopeLength / 2, 0, 0, DEBUG and 1, 0, false)

    constraint.ballsocketadv(wheel, plate, 0, 0, Vector(0), Vector(0), 0, 0, Vector(-180, -0.1, -180), Vector(180, 0.1, 180), Vector(0), true, true)
    constraint.ballsocketadv(wheel, plate, 0, 0, Vector(0), Vector(0), 0, 0, Vector(-180, -180, -0.1), Vector(180, 180, 0.1), Vector(0), true, true)
    constraint.ballsocketadv(wheel, plate, 0, 0, Vector(0), Vector(0), 0, 0, Vector(-180, -0.1, -0.1), Vector(180, 0.1, 0.1), Vector(0), true, true)

end

Chassis.createAxle = async* function(self, pos, ang)
    local right, left = TaskAll {self:createWheel(pos:clone():setX(-pos.x), -ang), self:createWheel(pos, ang)}
    self:createSuspension(unpack(right))
    self:createSuspension(unpack(left))
    right[1]:setFrozen(false)
    left[1]:setFrozen(false)
    return {
        right = right[2],
        left = left[2],
        rightw = right[1],
        leftw = left[1]
    }
end
Chassis.createSeat = async* function(self, pos, ang)
    while not prop.canSpawn() do
        sleep(250)
    end

    local seat = prop.createSeat(self.base:localToWorld(pos), self.base:localToWorldAngles(ang), "models/nova/chair_office02.mdl", true)
    seat:setParent(self.base)
    seat:setSolid(true)
    seat:setNocollideAll(true)
    seat:setNoDraw(not DEBUG)
    return seat
end

function Chassis:_onCreated()
    self.car:onChassisCreated(self)
    self:onCreated(self)
end

-- STUB
function Chassis:onCreated()
end

return Chassis
