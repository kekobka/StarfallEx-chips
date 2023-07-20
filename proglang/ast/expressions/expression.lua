--@name Expression

local Expression = class("Expression", Node)

function Expression:eval() 
end

function Expression:accept(visitor)
    visitor:visit(self)
end




return Expression
