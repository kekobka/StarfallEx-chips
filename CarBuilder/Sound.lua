-- @client
-- @include libs/Task.txt
local Task = require("libs/Task.txt")

local maxThrottle = 100
local webVolumeBoost = 1
local redline = 7000
local additionalCurveWidth = 10
local mapRpmToSoundRpms = true

local onVolume = 1
local offVolume = 0.5
local sounds = {
    [900] = "https://github.com/koptilnya/gmod-data/raw/main/engine_sounds/bmw_s54/ext_e30s54_idle.ogg",
    [2500] = "https://github.com/koptilnya/gmod-data/raw/main/engine_sounds/bmw_s54/ext_e30s54_on_2500.ogg",
    [4000] = "https://github.com/koptilnya/gmod-data/raw/main/engine_sounds/bmw_s54/ext_e30s54_on_4000.ogg",
    -- [5500] = "https://github.com/koptilnya/gmod-data/raw/main/engine_sounds/bmw_s54/ext_e30s54_on_5500.ogg",
    [6750] = "https://github.com/koptilnya/gmod-data/raw/main/engine_sounds/bmw_s54/ext_e30s54_on_6750.ogg",
    [8500] = "https://github.com/koptilnya/gmod-data/raw/main/engine_sounds/bmw_s54/ext_e30s54_on_8500.ogg"
}
local maxValue = 8500
function SetSoundRedline(v)
    redline = v
end
local soundCount = 5
local loaded = false
local soundObjects = {}
local soundRpms = {}

Task(function()

    for soundRpm, soundPath in pairs(sounds) do
        
        local sound = await* bass.loadURL(soundPath, "3d noblock noplay")
        soundObjects[soundRpm] = sound
        table.insert(soundRpms,soundRpm)
        ::CONTINUE::
    end
    table.sort(soundRpms)
    loaded = true
end)

local active = false

net.receive("ENGINE_ACTIVE", function()
    active = net.readBool()

    -- if active and loaded then
    --     for _, sound in pairs(soundObjects) do
    --         sound:play()
    --         sound:setVolume(0)
    --         sound:setPitch(0)
    --         sound:setLooping(true)
    --         sound:setPos(chip():getPos())
    --     end
    -- else
    --     for _, sound in pairs(soundObjects) do
    --         sound:pause()
    --     end
    -- end
end)

local throttle = 0
local engineRpm = 0

net.receive("ENGINE_FULLRPM", function()
    if not loaded then
        return
    end
    engineRpm = net.readUInt(14) * (mapRpmToSoundRpms and (maxValue / redline) or 1)
    throttle = math.max(net.readFloat(), 0)
end)

local smoothRpm = 0
local smoothThrottle = 0

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

hook.add("think", table.address({}), function()
    if not active or not loaded then
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
        local c = fade(smoothRpm, min - additionalCurveWidth, rpm, max + additionalCurveWidth)
        local vol = c * map(smoothThrottle, 0, 1, offVolume, onVolume)
        local soundObject = soundObjects[rpm]
        soundObject:setVolume(vol)
        soundObject:setPitch(smoothRpm / rpm)
        soundObject:setPos(chip():getPos())
        soundObject:pause()
        soundObject:play()
        ::CONTINUE::
    end
end)

