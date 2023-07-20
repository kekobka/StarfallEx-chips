--@name Statement


local Statement = class("Statement", Node)

function Statement:execute()
end

function Statement:accept(visitor)

end


return Statement


