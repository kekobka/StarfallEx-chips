-- @client
-- @include libs/Task.txt
local Task = require("libs/Task.txt")
local Sound = class("Sound")


local function map(x, a, b, c, d)
    return (x - a) / (b - a) * (d - c) + c
end

local function fade(n, min, mid, max)
    if n < min or n > max then
        return 0
    end

    if n > mid then
        min = mid - (max - mid)
    end

    return math.cos((1 - ((n - min) / (mid - min))) * (math.pi / 2))
end

function Sound:initialize(redline, parent, sounds)
    local sounds = sounds or {
        [900] = "https://raw.githubusercontent.com/koptilnya/gmod-data/main/engine_sounds/bmw_s54/ext_e30s54_idle.ogg",
        [2500] = "https://raw.githubusercontent.com/koptilnya/gmod-data/main/engine_sounds/bmw_s54/ext_e30s54_on_2500.ogg",
        [4000] = "https://raw.githubusercontent.com/koptilnya/gmod-data/main/engine_sounds/bmw_s54/ext_e30s54_on_4000.ogg",
        [6750] = "https://raw.githubusercontent.com/koptilnya/gmod-data/main/engine_sounds/bmw_s54/ext_e30s54_on_6750.ogg",
        [8500] = "https://raw.githubusercontent.com/koptilnya/gmod-data/main/engine_sounds/bmw_s54/ext_e30s54_on_8500.ogg"
    }
    local redline = redline or 7000
    self.active = false
    local soundObjects = {}
    local soundRpms = {}
    local maxValue = 0
    local throttle = 0
    local engineRpm = 0
    local smoothRpm = 0
    local smoothThrottle = 0

    Task(function()
        for soundRpm, soundPath in pairs(sounds) do
            
            local sound = await* bass.loadURL(soundPath, "3d noblock noplay")
            soundObjects[soundRpm] = sound
            table.insert(soundRpms,soundRpm)
            if maxValue < soundRpm then
                maxValue = soundRpm
            end
        end
        table.sort(soundRpms)
        hook.add("think", table.address({}), function()
            if not self.active then
                return
            end
            smoothRpm = smoothRpm * (1 - 0.2) + engineRpm * 0.2
            smoothThrottle = smoothThrottle * (1 - 0.1) + throttle * 0.1
        
            for n, rpm in ipairs(soundRpms) do
                if not soundObjects[rpm] then
                    goto CONTINUE
                end
                local min = n == 1 and -100000 or soundRpms[n - 1]
                local max = n == #soundRpms and 100000 or soundRpms[n + 1]
                local c = fade(smoothRpm, min - 10, rpm, max + 10)
                local vol = c * map(smoothThrottle, 0, 1, 0.5, 1)
                local soundObject = soundObjects[rpm]
                soundObject:setVolume(vol)
                soundObject:setPitch(smoothRpm / rpm)
                soundObject:setPos(parent:getPos())
                soundObject:pause()
                soundObject:play()
                ::CONTINUE::
            end
        end)
    end)

    net.receive("ENGINE_ACTIVE", function()
        self.active = net.readBool()
    end)
    net.receive("ENGINE_FULLRPM", function()
        engineRpm = net.readUInt(14) * (maxValue / redline)
        throttle = math.max(net.readFloat(), 0)
    end)
end


return Sound



