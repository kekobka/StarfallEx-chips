--@server
local TICK_INTERVAL = game.getTickInterval()
local RAD_TO_RPM = 9.5493

local Engine = class("Engine")

function Engine:initialize(Transmission, data)
    self.Transmission = Transmission

    self.maxRPM = data.maxRPM or 6000
    self.idleRPM = data.idleRPM or 900
    self.flywheelMass = data.FlywheelMass or 2.4
    self.flywheelRadius = data.FlywheelRadius or 0.418
    self.maxTorque = data.maxTorque or 350
    self.initTorqueMap = data.torqueMap or {0.2, 0.5, 0.7, 0.8, 1, 0.3, 0.2}

    self.startFriction = data.StartFriction or 0
    self.frictionCoeff = data.FrictionCoeff or 0.01
    self.limiterDuration = data.LimiterDuration or 0.09

    self._fwInertia = self.flywheelMass * self.flywheelRadius ^ 2 / 2
    self._limiterTime = 0
    self.torque = 0
    self.rpmFrac = 0
    self.rpm = 0
    self.friction = 0
    self.masterThrottle = 0

    self.Perfomance = self:CalcEnginePerformance()
    self.torqueMap = self.Perfomance.TorqueMap
    net.start("ENGINE_ACTIVE")
    net.writeBool(true)
    net.send()
end

function Engine:getThrottle()
    local driver = self.Transmission.car:getDriver()
    if driver then
        return driver:keyDown(IN_KEY.FORWARD) and 1 or 0
    end
    return 0
end

function Engine:think()
    local throttle = self:getThrottle()

    self.rpmFrac = math.clamp((self.rpm - self.idleRPM) / (self.maxRPM - self.idleRPM), 0, 1)
    self.friction = self.startFriction - self.rpm * self.frictionCoeff

    local tqIdx = math.clamp(math.floor(self.rpmFrac * #self.torqueMap), 1, #self.torqueMap)
    local maxInitialTorque = self.torqueMap[tqIdx] - self.friction

    local idleFadeStart = math.clamp(math.remap(self.rpm, self.idleRPM - 300, self.idleRPM, 1, 0), 0, 1)
    local idleFadeEnd = math.clamp(math.remap(self.rpm, self.idleRPM, self.idleRPM + 600, 1, 0), 0, 1)

    local additionalEnergySupply = idleFadeEnd * (-self.friction / maxInitialTorque) + idleFadeStart

    if self.rpm > self.maxRPM then
        throttle = 0
        self._limiterTime = timer.systime()
    else
        throttle = timer.systime() >= self._limiterTime + self.limiterDuration and throttle or 0
    end
    
    self.masterThrottle = math.clamp(additionalEnergySupply + throttle, 0, 1)

    local realInitialTorque = maxInitialTorque * self.masterThrottle

    self.torque = realInitialTorque + self.friction
    
    self.rpm = self.rpm + (self.torque - self.clutch.torque) / self._fwInertia * RAD_TO_RPM * TICK_INTERVAL
    self.rpm = math.max(self.rpm, 0)
    
    net.start("ENGINE_RPM")
    net.writeFloat(self.rpm / self.maxRPM)
    net.send(nil, true)

    net.start("ENGINE_FULLRPM")
    net.writeUInt(self.rpm, 14)
    net.writeFloat(self.masterThrottle)
    net.send(nil, true)
end

function Engine:CalcCurve(Pos)
    local Count = #self.initTorqueMap

    if Count < 3 then
        return 0
    end

    if Pos <= 0 then
        return self.initTorqueMap[1]
    elseif Pos >= 1 then
        return self.initTorqueMap[Count]
    end

    local T = (Pos * (Count - 1)) % 1
    local Current = math.floor(Pos * (Count - 1) + 1)
    local P0 = self.initTorqueMap[math.clamp(Current - 1, 1, Count - 2)]
    local P1 = self.initTorqueMap[math.clamp(Current, 1, Count - 1)]
    local P2 = self.initTorqueMap[math.clamp(Current + 1, 2, Count)]
    local P3 = self.initTorqueMap[math.clamp(Current + 2, 3, Count)]

    return 0.5 * ((2 * P1) + (P2 - P0) * T + (2 * P0 - 5 * P1 + 4 * P2 - P3) * T ^ 2 + (3 * P1 - P0 - 3 * P2 + P3) * T ^ 3)
end

---Calculates the performance characteristics of an engine, given a torque curve, max torque (in nm), idle, and redline rpm
function Engine:CalcEnginePerformance()
    local PeakTorque = 0
    local peakTqRPM = 0
    local peakPower = 0
    local peakPowerRPM = 0
    local powerTable = {} -- Power at each point on the curve for use in powerband calc
    local tqTable = {} -- Power at each point on the curve for use in powerband calc
    local res = 500 -- Iterations for use in calculating the curve, higher is more accurate

    -- Calculate peak torque/power RPM
    for i = 0, res do
        local rpm = i / res * self.maxRPM
        local perc = math.remap(rpm, self.idleRPM, self.maxRPM, 0, 1)
        local curTq = self:CalcCurve(perc) * self.maxTorque
        local power = curTq * rpm / 9548.8

        powerTable[i] = power
        table.insert(tqTable, curTq)

        if power > peakPower then
            peakPower = power
            peakPowerRPM = rpm
        end

        if curTq > PeakTorque then
            PeakTorque = curTq
            peakTqRPM = rpm
        end
    end

    -- Find the bounds of the powerband (within 10% of its peak)
    local powerbandMinRPM
    local powerbandMaxRPM

    for i = 0, res do
        local powerFrac = powerTable[i] / peakPower
        local rpm = i / res * self.maxRPM

        if powerFrac > 0.9 and not powerbandMinRPM then
            powerbandMinRPM = rpm
        end

        if (powerbandMinRPM and powerFrac < 0.9 and not powerbandMaxRPM) or (i == res and not powerbandMaxRPM) then
            powerbandMaxRPM = rpm
        end
    end

    return {
        PeakTqRPM = peakTqRPM,
        PeakPower = peakPower,
        PeakTorque = PeakTorque,
        PeakPowerRPM = peakPowerRPM,
        PowerbandMinRPM = powerbandMinRPM,
        PowerbandMaxRPM = powerbandMaxRPM,
        TorqueMap = tqTable
    }
end

return Engine
