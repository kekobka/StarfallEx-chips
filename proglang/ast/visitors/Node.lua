--@name Node


Node = class("Node")

function Node:accept(visitor)
    visitor:visit(self)
end

