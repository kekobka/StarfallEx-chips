--@name SubtractionStatement

--@include ./Statement.lua

local Statement = require("./Statement.lua")

SubtractionStatement = class("SubtractionStatement", Statement)


function SubtractionStatement:initialize(var, ex)
    self.var = var
    self.ex = ex
end


function SubtractionStatement:execute()
    local result = self.ex:eval()
    local var = Variables[self.var]
    if not var then
        return throw("can't substract a nil value")
    end
    Variables[self.var] = var - result
end

function SubtractionStatement:__tostring()
    return self.var.." = "..tostring(self.ex)
end














































































