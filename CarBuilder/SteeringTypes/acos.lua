--@server
--@include ./Default.lua
local AcosSteering = class("AcosSteering",require("./Default.lua"))

function AcosSteering:initialize(car, body, axles, data)
    self.car = car
    self.body = body
    
    self.lock = data.lock
    self.axles = axles
    self.steerang = 0
    self.caster = data.caster or 0
    self.camber = data.camber or 0
    self.steerAng = 0
    self.accerman = data.accerman or 0
    
    
end
local function getWheelSlip(base, slave, axle)
    local vel = base:getVelocity()

    local velDirection = vel:getNormalized():setZ(0)
    local angDirection = -slave:getRight():getRotated(-axle.ang)

    local dot = angDirection:dot(velDirection) 
    
    return math.deg(math.acos(dot)) - 90
end
function AcosSteering:getCorrection()

    local totalFrictionForce = 0
    for idx, axle in next, self.axles do
        if not axle.steer then
            goto CONTINUE
        end

        local leftwheel,leftplate = axle.leftw, axle.left
        local rightwheel,rightplate = axle.rightw, axle.right
        
        local wheelLeftFrictionForce = getWheelSlip(self.body, leftplate, axle)
        local wheelRightFrictionForce = getWheelSlip(self.body, rightplate, axle)
        totalFrictionForce = totalFrictionForce + (wheelLeftFrictionForce + wheelRightFrictionForce) / 2
        ::CONTINUE::
    end
    return totalFrictionForce * -math.sign(self.body:getLocalVelocity().y) * 0.3
end

return AcosSteering
