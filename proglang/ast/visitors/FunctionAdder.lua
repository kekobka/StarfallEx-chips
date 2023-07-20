--@name FunctionAdder

FunctionAdder = class("FunctionAdder", Visitor)


function FunctionAdder:visit(s)
    s:accept(self)
end
