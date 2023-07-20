--@name ConstantExpression

--@include ./expression.lua

local Expression = require("./expression.lua")
ConstantExpression = class("ConstantExpression", Expression)

function ConstantExpression:initialize(value, t)

    self.name = value

    self.type = t or type(self.name)
end


function ConstantExpression:eval()
    return Variables[self.name]
end

function ConstantExpression:__tostring()
    return tostring(self.name)
end




