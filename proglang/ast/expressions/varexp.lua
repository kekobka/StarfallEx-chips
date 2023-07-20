--@name VariableExpression

--@include ./expression.lua

local Expression = require("./expression.lua")
VariableExpression = class("VariableExpression", Expression)


function VariableExpression:initialize(value, t)
    self.name = value
    self.type = t or type(self.value)
end


function VariableExpression:eval()
    return self.value
end

function VariableExpression:__tostring()
    return tostring(self.value)
end