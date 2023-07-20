--@name UnaryExpression

--@include ./expression.lua

local Expression = require("./expression.lua")
UnaryExpression = class("UnaryExpression", Expression)


function UnaryExpression:initialize(operation, expr1)
    self.operation = operation
    self.expr1 = expr1
end


function UnaryExpression:eval()
    if self.operation == "-" then
        return -self.expr1:eval()
    end
    
    return self.expr1:eval()
end

function UnaryExpression:__tostring()
    return (self.operation or "") .. tostring(self.expr1)
end

