--@name FunctionDefineStatement

--@include ./Statement.lua
local Statement = require("./Statement.lua")


FunctionDefineStatement = class("FunctionDefineStatement", Statement)


function FunctionDefineStatement:initialize(name, argTypes, argNames, body)
    self.name = name
    self.argNames = argNames
    self.argTypes = argTypes
    self.body = body
end


function FunctionDefineStatement:execute()
    FUNCTIONS[self.name.."( "..table.concat(self.argTypes,", ").." )"] = UserFunctionStatement(self.argNames, self.body)
end

function FunctionDefineStatement:accept(visitor)
    self.body:accept(visitor)
    self:execute()
end

function FunctionDefineStatement:__tostring()
    local result = "def " .. self.name .. " ( "
    if #self.argTypes == 0 then
        result = result .. "void )"
    else
        for i, type in next, self.argTypes do
            result = result .. tostring(type).. ": " .. self.argNames[i] .. ", " 
        end
        result = result:sub(1,-3) .. " )"
    end
    return result .. " { \n\t" .. tostring(self.body) .. "}"
end


