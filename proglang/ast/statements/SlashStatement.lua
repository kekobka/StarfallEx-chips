--@name SlashStatement

--@include ./Statement.lua

local Statement = require("./Statement.lua")
SlashStatement = class("SlashStatement", Statement)


function SlashStatement:initialize(var, ex)
    self.var = var
    self.ex = ex
end


function SlashStatement:execute()
    local result = self.ex:eval()
    local var = Variables[self.var]
    if not var then
        return throw("can't divide a nil value")
    end
    Variables[self.var] = var / result
end

function SlashStatement:__tostring()
    return self.var.." = "..tostring(self.ex)
end


