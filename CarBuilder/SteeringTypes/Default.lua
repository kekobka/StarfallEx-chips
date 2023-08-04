--@server
local Steering = class("Steering")

local noInputCorrMul = 0.8
local inputCorrMul = 0.8

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
    self.velL = 0
    
end

function Steering:think()
    
    self.velL = self.car.body:getLocalVelocity():getLength()
    local lerpFactor = math.clamp((self.velL / 39.37 * 0.07), 0, 1)
    local correction = math.lerp(lerpFactor, 0, self:getCorrection() or 0)
    self.steerang = self.steerang / math.min(self.velL/100000 + 1,2)
    local driver = self:getDriver()
    local isInputActive
    if driver then
        local keyA = driver:keyDown(IN_KEY.MOVELEFT)
        local keyD = driver:keyDown(IN_KEY.MOVERIGHT)
        isInputActive = keyA or keyD
        self.steerang = self.steerang + (keyA and 1 or 0) - (keyD and 1 or 0)
    end
    local correction = correction * (isInputActive and inputCorrMul or noInputCorrMul)
    local correction = correction ~= correction and 0 or correction
    self.steerang = self.steerang - correction
    
    self.steerang = math.clamp(self.steerang, -self.lock, self.lock)
    
end

function Steering:applyAngles()
    
    local ang = self.steerang
    for id, axle in next, self.axles do

        axle.right:setFrozen(true)
        axle.left:setFrozen(true)
        local caster = axle.caster or self.caster
        local camber = axle.camber or self.camber
        local accerman = axle.accerman or self.accerman
        if axle.steer then
            axle.right:setAngles(self.body:localToWorldAngles(Angle(camber + (ang / 90 * caster), ang + math.sin(math.rad(ang)) ^2 * accerman, 0)))
            axle.left:setAngles(self.body:localToWorldAngles(Angle(-camber + (ang / 90 * caster), ang + math.sin(math.rad(ang)) ^2 * accerman, 0 )))
            if self.velL > 360 then
                axle.rightw:applyForceCenter(axle.rightw:getRight() * axle.rightw:getMass() * 5) 
                axle.leftw:applyForceCenter(axle.leftw:getRight() * axle.leftw:getMass() * 5) 
            end
        else
            axle.right:setAngles(self.body:localToWorldAngles(Angle(camber, 0, 0 )))
            axle.left:setAngles(self.body:localToWorldAngles(Angle(-camber, 0, 0 )))
            if self.velL > 360 then
                axle.rightw:applyForceCenter(axle.rightw:getRight() * axle.rightw:getMass() * 4) 
                axle.leftw:applyForceCenter(axle.leftw:getRight() * axle.leftw:getMass() * 4) 
            end
        end
    end
end
function Steering:getDriver()
    return self.car:getDriver()
end
function Steering:getSteerAngle()
    return self.steerang
end

function Steering:getCorrection()
    return 0
end

return Steering
