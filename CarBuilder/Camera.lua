local pl = player()
local dist = 250
local localview = false
local dinamicfov,razniza = 0,0
CAR_SPEED = 0
local function getFOV()
    local sqrt = math.sqrt(CAR_SPEED) * 2
    razniza = math.lerp(0.1, razniza, sqrt * 1.5 - dinamicfov)
    dinamicfov = math.lerp(math.clamp(dinamicfov / 10, 0.1, 1), dinamicfov, sqrt)
    return razniza
end
hook.add("calcview", "normalize", function(origin, angles, fov, znear, zfar)
    if not pl:inVehicle() then
        return
    end
    local veh = pl:getVehicle():getParent()
    local min, max = veh:worldSpaceAABB()
    local addfov = getFOV()
    if localview then
        origin = eyePos()
    else
        origin = (max + min) / 2 - eyeVector() * dist + Vector(0, 0, 25 - addfov*2)
    end
    
    return {
        origin = origin,
        angles = angles,
        fov = fov / 1.2 + (localview and 15 or 0) + addfov,
        znear = znear,
        zfar = zfar,
        drawviewer = not localview,
        ortho = ortho
    }
end)

hook.add("mouseWheeled", "normalize", function(delta)
    dist = dist - delta * 8
end)
hook.add("inputPressed", "normalize", function(key)
    if key == KEY.LCONTROL then
        localview = not localview
    end
end)
