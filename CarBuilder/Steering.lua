--@server
local Steering = class("Steering")

local noInputCorrMul = 0.8
local inputCorrMul = 0.5

local velLerpMultiplier = 0.07
local SATMultiplier = 1
local maxSATForce = 15

function Steering:initialize(car, body, axles, data)
    self.car = car
    self.body = body
    
    self.lock = data.lock
    self.axles = axles
    self.steerang = 0
    self.caster = data.caster or 0
    self.camber = data.camber or 0
    self.steerAng = 0
    self.accerman = data.accerman or 0
    local isInputActive

    hook.add("Think", table.address(self), function()
        local lerpFactor = math.clamp((self.body:getLocalVelocity():getLength() / 39.37 * 0.07), 0, 1)
        local correction = math.lerp(lerpFactor, 0, self:getCorrection())
        
        local driver = self:getDriver()
        if driver then
            local keyA = driver:keyDown(IN_KEY.MOVELEFT)
            local keyD = driver:keyDown(IN_KEY.MOVERIGHT)
            isInputActive = keyA or keyD
            
            self.steerAng = math.lerp(0.15, self.steerAng, (keyA and 1 or 0) - (keyD and 1 or 0))
        end
        self.steerang = self.steerang + self.steerAng
        local correction = correction * (isInputActive and inputCorrMul or noInputCorrMul)
        local correction = correction ~= correction and 0 or correction
        self.steerang = self.steerang - correction
        
        self.steerang = math.clamp(self.steerang, -self.lock, self.lock)
        local ang = self.steerang
        for id, axle in next, axles do

            axle.right:setFrozen(true)
            axle.left:setFrozen(true)
            local caster = axle.caster or self.caster
            local camber = axle.camber or self.camber
            local accerman = axle.accerman or self.accerman
            if axle.steer then
                
                axle.right:setAngles(body:localToWorldAngles(Angle(camber + (ang / 90 * caster), ang + math.sin(math.rad(ang)) ^2 * accerman, 0)))
                axle.left:setAngles(body:localToWorldAngles(Angle(-camber + (ang / 90 * caster), ang + math.sin(math.rad(ang)) ^2 * accerman, 0 )))
            else
                axle.right:setAngles(body:localToWorldAngles(Angle(camber, 0, 0 )))
                axle.left:setAngles(body:localToWorldAngles(Angle(-camber, 0, 0 )))
            end
        end
    end)
    
end

function Steering:getDriver()
    return self.car:getDriver()
end

function Steering:getSteerAngle()
    return self.steerang
end

local KG_TO_N = 1 / 9.80
local SATCurve = { Vector(0, 0.01), Vector(0.05, 1.5), Vector(0.15, 0.1), Vector(0.2, -0.3) }
local pow = math.pow
local function cubic(points, t)
    return Vector(
        (pow(1 - t, 3) * points[1].x) + (3 * pow(1 - t, 2) * t * points[2].x) + (3 * (1 - t) * pow(t, 2) * points[3].x) + (pow(t, 3) * points[4].x),
        (pow(1 - t, 3) * points[1].y) + (3 * pow(1 - t, 2) * t * points[2].y) + (3 * (1 - t) * pow(t, 2) * points[3].y) + (pow(t, 3) * points[4].y)
    )
end

local function evalSATCurve(slip)
    local tDiff = math.abs(slip) / 90
    return cubic(SATCurve, tDiff).y * math.sign(slip)
end

local function getWheelSlip(base, slave, axle)
    local vel = base:getVelocity()

    local velDirection = vel:getNormalized():setZ(0)
    local angDirection = -slave:getRight():getRotated(-axle.ang)

    local dot = angDirection:dot(velDirection) 
    
    return math.deg(math.acos(dot)) - 90
end

function Steering:getWheelFrictionForce(base, wheel, slave, axle)
    local physObj = wheel:getPhysicsObject()
    local slip = getWheelSlip(base, slave, axle)

    local load = physObj:getStress() / KG_TO_N
    local inertia = physObj:getInertia():getLength()
    local friction = wheel:getFriction()
    -- local mechanicalTrail = wheel:getModelRadius() / 39.37 * 2 * math.pi * (caster or self.caster)
    local factor = math.clamp(load * friction, -maxSATForce, maxSATForce)
    local sidewaysFriction = factor * evalSATCurve(slip)
    
    return sidewaysFriction / 6
    -- return (factor * evalSATCurve(slip) * math.sign(slip) + mechanicalTrail * math.sin(math.rad(slip))) / KG_TO_N / inertia 
end

function Steering:getCorrection()
    local totalFrictionForce = 0

    for idx, axle in next, self.axles do
        if not axle.steer then
            goto CONTINUE
        end

        local leftwheel,leftplate = axle.leftw, axle.left
        local rightwheel,rightplate = axle.rightw, axle.right
        
        local wheelLeftFrictionForce = self:getWheelFrictionForce(self.body, leftwheel, leftplate, axle)
        local wheelRightFrictionForce = self:getWheelFrictionForce(self.body, rightwheel, rightplate, axle)

        totalFrictionForce = totalFrictionForce + wheelLeftFrictionForce + wheelRightFrictionForce
        ::CONTINUE::
    end
    
    return totalFrictionForce * SATMultiplier
end

return Steering
