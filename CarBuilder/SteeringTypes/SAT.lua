--@server
--@include ./Default.lua
local SATSteering = class("SATSteering",require("./Default.lua"))

local noInputCorrMul = 0.7
local inputCorrMul = 0.3

local SATMultiplier = 1
local maxSATForce = 30

function SATSteering:initialize(car, body, axles, data)
    self.car = car
    self.body = body
    
    self.lock = data.lock or 45
    self.axles = axles
    self.steerang = 0
    self.caster = data.caster or 0
    self.camber = data.camber or 0
    self.steerAng = 0
    self.accerman = data.accerman or 0
    
    
end

local KG_TO_N = 1 / 9.80

local SATCurve = { 0.01, 1.2, 0.1, -0.3 }
local pow = math.pow

local function cubic(t)
    return (pow(1 - t, 3) * SATCurve[1]) + 
    (3 * pow(1 - t, 2) * t * SATCurve[2]) + 
    (3 * (1 - t) * pow(t, 2) * SATCurve[3]) + 
    (pow(t, 3) * SATCurve[4])
end

local function evalSATCurve(slip)
    local tDiff = math.abs(slip) / 90
    return cubic(tDiff) * math.sign(slip)
end

local function getWheelSlip(base, slave, axle)
    local vel = base:getVelocity()

    local velDirection = vel:getNormalized():setZ(0)
    local angDirection = -slave:getRight():getRotated(-axle.ang)

    local dot = angDirection:dot(velDirection) 
    
    return math.deg(math.acos(dot)) - 90
end

function SATSteering:getWheelFrictionForce(base, wheel, slave, axle)
    local physObj = wheel:getPhysicsObject()
    local slip = getWheelSlip(base, slave, axle)

    local load = physObj:getStress() / KG_TO_N
    local inertia = physObj:getInertia():getLength()
    local friction = wheel:getFriction()
    -- local mechanicalTrail = wheel:getModelRadius() / 39.37 * 2 * math.pi  --* self.caster
    local factor = math.clamp(load * friction, -maxSATForce, maxSATForce)
    local sidewaysFriction = factor * evalSATCurve(slip)
    
    return sidewaysFriction / 6
    -- return (factor * evalSATCurve(slip) * math.sign(slip) + mechanicalTrail * math.sin(math.rad(slip))) / KG_TO_N / inertia 
end

function SATSteering:getCorrection()
    local totalFrictionForce = 0

    for idx, axle in next, self.axles do
        if not axle.steer then
            goto CONTINUE
        end

        local leftwheel,leftplate = axle.leftw, axle.left
        local rightwheel,rightplate = axle.rightw, axle.right
        
        local wheelLeftFrictionForce = self:getWheelFrictionForce(self.body, leftwheel, leftplate, axle)
        local wheelRightFrictionForce = self:getWheelFrictionForce(self.body, rightwheel, rightplate, axle)

        totalFrictionForce = totalFrictionForce + (wheelLeftFrictionForce + wheelRightFrictionForce) / 2
        ::CONTINUE::
    end
    
    return totalFrictionForce * SATMultiplier
end

return SATSteering
