--@name jalpa
--@include CarBuilder/included.lua
local CarBuilder = require("CarBuilder/included.lua")
if SERVER then
    chip():setPos(chip():getPos() + Vector(0, 0, 55))
    chip():setAngles(Angle(0, 90, 0))
    chip():setDrawShadow(false)
    Steerholo = hologram.create(chip():localToWorld(Vector(15.1382, 12.4933, -25 + 3.03781)), chip():localToWorldAngles(Angle(0, 90, 23.30 - 90)), "models/holograms/cube.mdl", Vector(0.1))
end
DEBUG = false

local Jalpa = CarBuilder {
    obj = "https://raw.githubusercontent.com/kekobka/valera/main/jalpa.obj",
    body = {
        obj = {"physics", "physics.001", "physics.002"},
        pos = Vector(0, 0, -25),
        ang = chip():getAngles()
    },
    transmission = {
        engine = {
            pos = Vector(-50,0,-25),
            maxRPM = 8000,
            maxTorque = 300,
            sounds = {
                [900] = "https://raw.githubusercontent.com/koptilnya/gmod-data/main/engine_sounds/bmw_s54/ext_e30s54_idle.ogg",
                [2500] = "https://raw.githubusercontent.com/koptilnya/gmod-data/main/engine_sounds/bmw_s54/ext_e30s54_on_2500.ogg",
                [4000] = "https://raw.githubusercontent.com/koptilnya/gmod-data/main/engine_sounds/bmw_s54/ext_e30s54_on_4000.ogg",
                [6750] = "https://raw.githubusercontent.com/koptilnya/gmod-data/main/engine_sounds/bmw_s54/ext_e30s54_on_6750.ogg",
                [8500] = "https://raw.githubusercontent.com/koptilnya/gmod-data/main/engine_sounds/bmw_s54/ext_e30s54_on_8500.ogg"
            }
        },
        gearbox = {
            type = 'MANUAL',
            shiftDuration = 0.2,
            shiftSmoothness = 0.3,
            ratios = {2.621, 1.902, 1.308, 1, 0.838},
            reverse = 3.382,
            axles = {{
                distributionCoeff = 0.7,
                finalDrive = 3.3,
                canHandBreak = true
            },{
                distributionCoeff = 0.3,
                finalDrive = 3.3
            }},
            clutch = {
                stiffness = 7,
                damping = 0.5,
                maxTorque = 10000
            }
        }

    },
    mesh = {
        body = {
            pos = Vector(0, 0, -25),
            color = Color(255, 255, 255),
            ang = chip():getAngles(),
            material = "phoenix_storms/pack2/interior_sides"
        },
        niz = {
            pos = Vector(0, 0, -25),
            color = Color(51, 51, 51),
            ang = chip():getAngles()
        },
        priborka = {
            pos = Vector(0, 0, -25),
            color = Color(151, 151, 151),
            material = "sprops/textures/sprops_cfiber1",
            ang = chip():getAngles()
        },
        steer = {
            parent = Steerholo,
            relative = Steerholo,
            color = Color(151, 151, 151)
        }

    },
    steering = {
        type = "SAT",
        lock = 45,
        camber = 3,
        caster = 14,
        accerman = 20
    },
    chassis = {
        RopeLength = 150,
        SuspensionTravel = 10,

        axles = {{
            pos = Vector(35, 51, -17), -- back
            ang = Angle(0, 90, 0),
            camber = 0
        }, {
            pos = Vector(33, -48.5, -16.5), -- front
            ang = Angle(0, 90, 0),
            steer = true

        }},
        seats = {{
            pos = Vector(12, 0, -32), -- left
            ang = Angle(0, 180, 10),
            driver = true
        }, {
            pos = Vector(-12, 0, -32), -- right
            ang = Angle(0, 180, 10)
        }}
    }
}

function Jalpa:onChassisCreated(Chassis)
    Steerholo:setParent(chip())
    chip():setParent(self.body)

end
function Jalpa:onCreated()

end

function Jalpa:think()
    self.mesh.steer.holo:setAngles(Steerholo:localToWorldAngles(Angle(0, Jalpa:getSteerAngle() * 9, 0)))
end

