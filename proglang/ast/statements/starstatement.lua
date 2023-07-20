--@name StarStatement

--@include ./Statement.lua

local Statement = require("./Statement.lua")
StarStatement = class("StarStatement", Statement)


function StarStatement:initialize(var, ex)
    self.var = var
    self.ex = ex
end


function StarStatement:execute()
    local result = self.ex:eval()
    local var = Variables[self.var]
    if not var then
        return throw("can't multiplicate a nil value")
    end
    Variables[self.var] = var * result
end

function StarStatement:__tostring()
    return self.var.." = "..tostring(self.ex)
end


