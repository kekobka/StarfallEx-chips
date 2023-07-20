--@name BinaryExpression

--@include ./expression.lua

local Expression = require("./expression.lua")

BinaryExpression = class("BinaryExpression", Expression)

local OPERATORS = {
    ["-"] = function(v1, v2)
        if isstring(v1) and isnumber(v2) then
            return v1:sub(1,-v2 - 1)
        end
        
        return v1 - v2
    end,
    ["*"] = function(v1, v2)
        
        if isstring(v1) and isnumber(v2) then
            return v1:rep(v2)
        end
        
        return v1 * v2
    end,
    ["/"] = function(v1, v2)
        return v1 / v2
    end,
    ["+"] = function(v1, v2)
        if isstring(v1) or isstring(v2) then
            v1 = tostring(v1)
            v2 = tostring(v2)
            return v1..v2
        end
        return v1 + v2
    end,
    ["^"] = function(v1, v2)
        return v1 ^ v2
    end,
    ["%"] = function(v1, v2)
        return v1 % v2
    end
} 

function BinaryExpression:initialize(operation, expr1, expr2)
    self.operation = operation
    self.expr1 = expr1
    self.expr2 = expr2
end


function BinaryExpression:eval()
    local v1 = self.expr1:eval()
    local v2 = self.expr2:eval()
    return OPERATORS[self.operation](v1, v2)
end

function BinaryExpression:__tostring()
    return tostring(self.expr1) .." ".. (self.operation or "") .." ".. tostring(self.expr2 or "")
end

