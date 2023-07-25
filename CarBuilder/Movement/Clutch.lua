local Clutch = class('Clutch')

function Clutch:initialize(data, gearbox, engine)
    self.stiffness = data.stiffness or 7
    self.damping = data.damping or 0.5
    self.maxTorque = data.maxTorque or 2000

    self.press = 0
    self.slip = 0
    self.targetTorque = 0
    self.torque = 0

    self.engine = engine
    self.gearbox = gearbox
end
local RPM_TO_RAD = 0.10472

function Clutch:getPress()
    local driver = self.engine.Transmission.car:getDriver()
    if driver then
        return driver:keyDown(IN_KEY.SPEED) and 1 or 0
    end
    return 0
end

function Clutch:think()
    local engRPM = self.engine.rpm
    local gboxRPM = self.gearbox.rpm
    
    local gboxRatio = self.gearbox.ratio
    local gboxRatioNotZero = gboxRatio ~= 0 and 1 or 0

    self.slip = ((engRPM - gboxRPM) * RPM_TO_RAD) * gboxRatioNotZero / 2
    self.targetTorque = math.clamp(self.slip * self.stiffness * (1 - self:getPress()), -self.maxTorque, self.maxTorque)

    self.torque = math.lerp(self.damping, self.torque, self.targetTorque)

end

return Clutch
