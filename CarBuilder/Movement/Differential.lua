--@server
local RAD_TO_RPM = 9.5493
local TICK_INTERVAL = game.getTickInterval()


local Differential = class("Differential")

function Differential:initialize(gearbox, data, DifferentialData)

    self.DifferentialData = DifferentialData
    self.gearbox = gearbox
    self.leftWheel = DifferentialData.leftw
    self.rightWheel = DifferentialData.rightw
    
    self.finalDrive = data.finalDrive or 2.2

    self.distributionCoeff = data.distributionCoeff or 1

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
    local simmetric = self.gearbox.torque * self.distributionCoeff * self.finalDrive
    local lock = (lwav - rwav) * inertia * TICK_INTERVAL * 2

    self.leftWheel:applyTorque((simmetric - lock) * -self.leftWheel:getRight())
    self.rightWheel:applyTorque((simmetric + lock) * self.rightWheel:getRight())

    self.lwav, self.rwav = self:getAngleVelocity()
    self.avgRPM = self:getRPM()
    self.avgRPM = self.avgRPM * self.finalDrive

end




return Differential
