--@server
--@includedir ./SteeringTypes/
local steeringTypes = requiredir("./SteeringTypes/")
local SteeringTypes = {}

for path,Class in next, steeringTypes do
    local type = string.getFileFromFilename(path):sub(1,-5)
    Class.static.type = type
    SteeringTypes[type:lower()] = Class
end

local SteeringFabric = class("SteeringFabric")

function SteeringFabric:initialize(car, body, axles, data)
    data.type = data.type:lower()
    self.steering = SteeringTypes[data.type:lower()](car, body, axles, data)
end

function SteeringFabric:getDriver()
    return self.steering.car:getDriver()
end

function SteeringFabric:getSteerAngle()
    return self.steering.steerang
end
function SteeringFabric:think()
    self.steering:think()
    self.steering:applyAngles()
end

return SteeringFabric
