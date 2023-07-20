--@name DecrementStatement

--@include ./Statement.lua

local Statement = require("./Statement.lua")

DecrementStatement = class("DecrementStatement", Statement)


function DecrementStatement:initialize(var)
    self.var = var

end


function DecrementStatement:execute()
    local var = Variables[self.var]
    if not var then
        return throw("can't decrement a nil value")
    end

    Variables[self.var] = var - 1
end

function DecrementStatement:__tostring()
    return self.var.."--"
end
