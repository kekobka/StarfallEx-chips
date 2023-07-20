--@name AdditionStatement

--@include ./Statement.lua

local Statement = require("./Statement.lua")
AdditionStatement = class("AdditionStatement", Statement)


function AdditionStatement:initialize(var, ex)
    self.var = var
    self.ex = ex
end


function AdditionStatement:execute()
    local result = self.ex:eval()
    local var = Variables[self.var]
    if not var then
        return throw("can't add a nil value")
    end
    Variables[self.var] = var + result
end

function AdditionStatement:__tostring()
    return self.var.." = "..tostring(self.ex)
end


