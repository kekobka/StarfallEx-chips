--@name ContinueStatement

--@include ./Statement.lua

local Statement = require("./Statement.lua")
ContinueStatement = class("ContinueStatement", Statement)

function ContinueStatement:execute()
    return throw("continue",-999)
end

function ContinueStatement:__tostring()
    return "continue"
end