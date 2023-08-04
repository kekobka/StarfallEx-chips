--@server

--@include ../Differential.lua
local Differential = require("../Differential.lua")


local ManualGearbox = class("ManualGearbox")

function ManualGearbox:initialize(Transmission, axles, data)
    self.Transmission = Transmission

    self.type = data.type 
    self.shiftDuration = data.shiftDuration or 0.2
    self.shiftSmoothness = data.shiftSmoothness or 0.3
    self.ratios = data.ratios or {3.321, 1.902, 1.308, 1, 0.838}
    self.reverse = data.reverse or 3.382
    self.axles = {}
    for k, v in next, data.axles do
        table.insert(self.axles, Differential(self, v, axles[k]))
    end
    self.torque = 0
    self.gear = 0
    self.ratio = 0
    self.rpm = 0
    self.data = data
    self.shifting = false
    self._shiftDuration = 0
    self.keyshifting = false
    self._ratio = 0
end


function ManualGearbox:think()

    self._ratio =  self.ratio --timer.systime() >= self._shiftDuration + self.shiftDuration and self.ratio or math.lerp(self.shiftSmoothness, self._ratio, 0)

    local driver = self.Transmission.car:getDriver()
    if driver then
        local KEY = driver:keyDown(IN_KEY.ATTACK)
        local KEY2 = driver:keyDown(IN_KEY.ATTACK2)
        if KEY or KEY2 then
            if not self.keyshifting then
                local dir = (KEY and 1 or 0) - (KEY2 and 1 or 0)
                self:shift(dir)
            end
            self.keyshifting = true
        else
            self.keyshifting = false
        end
    end
    
    self.clutch:think()
    for k, axle in next, self.axles do
        axle:think()
    end
    
    self.torque = self.clutch.torque * self._ratio

    local maxAxlesRPM = math.max(unpack(table.map(self.axles, function(diff)
        return diff.avgRPM
    end)))
    

    self.rpm = maxAxlesRPM * self._ratio

end

function ManualGearbox:setGear(gear)
    if gear >= -1 and gear <= #self.ratios then
        self.gear = gear
        self:recalcRatio()
    end
    self._shiftDuration = timer.systime()
    net.start("GEARBOX_GEAR")
    net.writeInt(self.gear, 5)
    net.send(nil,false)
end

function ManualGearbox:shift(dir)
    self:setGear(self.gear + dir)
end

function ManualGearbox:recalcRatio()
    if self.gear == -1 then
        self.ratio = -self.reverse
    elseif self.gear == 0 then
        self.ratio = 0
    else
        self.ratio = self.ratios[self.gear]
    end
end


return ManualGearbox