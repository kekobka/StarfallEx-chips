--@name ConditionalExpression

--@include ./expression.lua

local Expression = require("./expression.lua")

ConditionalExpression = class("ConditionalExpression", Expression)

local OPERATORS = {
    ["=="] = function(v1, v2)
        return v1 == v2
    end,
    ["!="] = function(v1, v2)
        return v1 ~= v2
    end,
    ["<"] = function(v1, v2)
        if isnumber(v1) and isnumber(v2) then
            return v1 < v2
        end
        if isstring(v1) and isstring(v2) then
            return v1:len() < v2:len()
        end
    end,
    [">"] = function(v1, v2)
        if isnumber(v1) and isnumber(v2) then
            return v1 > v2
        end
        if isstring(v1) and isstring(v2) then
            return v1:len() > v2:len()
        end
    end,
    ["<="] = function(v1, v2)
        if isnumber(v1) and isnumber(v2) then
            return v1 <= v2
        end
        if isstring(v1) and isstring(v2) then
            return v1:len() <= v2:len()
        end
    end,
    [">="] = function(v1, v2)
        if isnumber(v1) and isnumber(v2) then
            return v1 >= v2
        end
        if isstring(v1) and isstring(v2) then
            return v1:len() >= v2:len()
        end
    end,
    ["&&"] = function(v1, v2)
        return v1 and v2
    end,
    ["&"] = function(v1, v2)
        return v1 and v2
    end,
    ["||"] = function(v1, v2)
        return v1 or v2
    end,
    ["|"] = function(v1, v2)
        return v1 or v2
    end,
} 

function ConditionalExpression:initialize(operation, expr1, expr2)
    self.operation = operation
    self.expr1 = expr1
    self.expr2 = expr2
end


function ConditionalExpression:eval()
    local v1 = self.expr1:eval()
    local v2 = self.expr2:eval()
    return OPERATORS[self.operation](v1, v2)
end

function ConditionalExpression:__tostring()
    return tostring(self.expr1) .." ".. (self.operation or "") .." ".. tostring(self.expr2 or "")
end

