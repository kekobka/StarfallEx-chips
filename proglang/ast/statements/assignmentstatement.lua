--@name AssignmentStatement

--@include ./Statement.lua

local Statement = require("./Statement.lua")

AssignmentStatement = class("AssignmentStatement", Statement)


function AssignmentStatement:initialize(var, type, ex, init)
    self.var = var
    if not init and VariablesTypes[self.var] == type then
        throw("Variable: ".. tostring(self.var) .. " as " .. type .." alredy exists", 1, true)
    end
    VariablesTypes[self.var] = type
    self.type = type or type(self.type)
    self.ex = ex
end

function _G.isany()
    return true
end
function AssignmentStatement:execute()
    local result = self.ex:eval()
    if not _G["is"..self.type](result) then
        return throw( tostring(result).. " is not a ".. tostring(self.type))
    end
    Variables[self.var] = result
    return result
end

function AssignmentStatement:__tostring()
    return tostring(self.type) .. " " .. tostring(self.var) .. " = " .. tostring(self.ex)
end


