--@server
local RAD_TO_RPM = 9.5493
local TICK_INTERVAL = game.getTickInterval()


local Differential = class("Differential")

function Differential:initialize(gearbox, data, DifferentialData)
    self.car = gearbox.Transmission.car
    self.DifferentialData = DifferentialData
    self.gearbox = gearbox
    self.leftWheel = DifferentialData.leftw
    self.rightWheel = DifferentialData.rightw
    
    self.finalDrive = data.finalDrive or 2.2
    self.canHandBreak = data.canHandBreak or false

    self.distributionCoeff = data.distributionCoeff or 1

    self.avgRPM = 0
    self.lwav = 0
    self.rwav = 0

    self.handbrake = nil
    self.handbrakeLeft = nil
    self.handbrakeRight = nil
end


function Differential:getAngleVelocity()
    local lwav = math.rad(self.leftWheel:getAngleVelocity()[2])
    local rwav = math.rad(-self.rightWheel:getAngleVelocity()[2])
    local awav = (lwav + rwav) / 2

    return lwav, rwav, awav
end

function Differential:isBrake()
    local driver = self.car:getDriver()
    if driver then
        return driver:keyDown(IN_KEY.BACK) and 1 or 0
    end
    return 0
end
function Differential:isHandBrake()
    local driver = self.car:getDriver()
    if driver then
        return driver:keyDown(IN_KEY.JUMP)
    end
    return false
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
    local brake = -self.avgRPM * self:isBrake() * 2
    if self.canHandBreak and self:isHandBrake() then
        self.leftWheel:setAngleVelocity(Vector())
        self.rightWheel:setAngleVelocity(Vector())
    else
        self.leftWheel:applyTorque((simmetric - lock + brake) * -self.leftWheel:getRight())
        self.rightWheel:applyTorque((simmetric + lock + brake) * self.rightWheel:getRight())
    end
    self.lwav, self.rwav = self:getAngleVelocity()
    self.avgRPM = self:getRPM()
    self.avgRPM = self.avgRPM * self.finalDrive

end




return Differential
