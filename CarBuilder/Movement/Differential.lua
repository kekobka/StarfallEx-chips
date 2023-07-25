--@server
local RAD_TO_RPM = 9.5493
local TICK_INTERVAL = game.getTickInterval()


local Differential = class("Differential")

function Differential:initialize(gearbox, data, DifferentialData)

    self.DifferentialData = DifferentialData
    self.gearbox = gearbox
    self.leftWheel = self.DifferentialData.leftw
    self.rightWheel = self.DifferentialData.rightw
    
    self.power = data.power or 1
    self.coast = data.coast or 1
    self.preload = data.preload or 10
    self.viscousCoeff = data.viscousCoeff or 0.9
    self.finalDrive = data.finalDrive or 1

    self.distributionCoeff = data.distributionCoeff or 1
    self.maxCorrectingTorque = data.maxCorrectingTorque or 200

    self.avgRPM = 0
    self.lwav = 0
    self.rwav = 0
end


function Differential:getAngleVelocity()
    local lwav = math.rad(self.leftWheel:getAngleVelocity()[2])
    local rwav = math.rad(-self.rightWheel:getAngleVelocity()[2])
    local awav = (lwav + rwav) / 2

    return lwav, rwav, awav
end

function Differential:getRPM()
    local _, _, awav = self:getAngleVelocity()

    return  awav * RAD_TO_RPM
end

function Differential:think()

    local lwav, rwav = self:getAngleVelocity()

    local inertia = self.leftWheel:getInertia().y + self.rightWheel:getInertia().y
    local simmetric = self.gearbox.torque * self.distributionCoeff * self.finalDrive / 2
    local lock = (lwav - rwav) / 2 * inertia * TICK_INTERVAL

    self.leftWheel:applyTorque((simmetric - lock) * 1.33 * -self.leftWheel:getRight())
    self.rightWheel:applyTorque((simmetric + lock) * 1.33 * self.rightWheel:getRight())

    self.lwav, self.rwav = self:getAngleVelocity()
    self.avgRPM = self:getRPM()
    self.avgRPM = self.avgRPM * self.finalDrive

end




return Differential
