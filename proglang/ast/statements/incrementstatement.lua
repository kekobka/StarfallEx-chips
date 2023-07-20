--@name IncrementStatement

--@include ./Statement.lua

local Statement = require("./Statement.lua")

IncrementStatement = class("IncrementStatement", Statement)


function IncrementStatement:initialize(var)
    self.var = var

end


function IncrementStatement:execute()
    local var = Variables[self.var]
    if not var then
        return throw("can't increment a nil value")
    end
    -- if VariablesTypes[self.var] == "string" then
    --     return throw("can't increment a string value")
    -- end
    Variables[self.var] = var + 1
end

function IncrementStatement:__tostring()
    return self.var.."++"
end
