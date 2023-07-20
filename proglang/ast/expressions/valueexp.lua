--@name ValueExpression

--@include ./expression.lua

local Expression = require("./expression.lua")
ValueExpression = class("ValueExpression", Expression)


function ValueExpression:initialize(value, t)
    self.value = value
    self.type = t or type(self.value)
end


function ValueExpression:eval()
    return self.value
end

function ValueExpression:__tostring()
    return tostring(self.value)
end


