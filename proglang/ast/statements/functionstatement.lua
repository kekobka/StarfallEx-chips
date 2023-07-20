--@name FunctionStatement

--@include ./Statement.lua

local Statement = require("./Statement.lua")

FunctionStatement = class("FunctionStatement", Statement)


function FunctionStatement:initialize(fn)
    self.fn = fn
end


function FunctionStatement:execute()
    return self.fn:eval()
end

function FunctionStatement:__tostring()
    return tostring(self.fn)
end



