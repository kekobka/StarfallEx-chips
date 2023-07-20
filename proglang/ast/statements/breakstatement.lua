--@name BreakStatement

--@include ./Statement.lua

local Statement = require("./Statement.lua")

BreakStatement = class("BreakStatement", Statement)

function BreakStatement:execute()
    return throw("break", -999)
end

function BreakStatement:__tostring()
    return "break"
end

