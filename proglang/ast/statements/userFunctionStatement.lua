--@name UserFunctionStatement
--@include ./Statement.lua

local Statement = require("./Statement.lua")

UserFunctionStatement = class("UserFunctionStatement", Statement)


function UserFunctionStatement:initialize(args, body)
    self.args = args or {}
    self.body = body
    self.custom = true
end


function UserFunctionStatement:getArgsCount()
    return table.count(self.args)
end

function UserFunctionStatement:getArgsNames(index)
    if index <= 0 or index > self:getArgsCount() then
        return self.args[index]
    end
end

function UserFunctionStatement:execute()
    self.body:execute()
end

function UserFunctionStatement:__tostring()
    return "fn: " .. table.concat(self.args,", ")
end


