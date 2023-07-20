--@name FUNCTIONS
local InternalFunction = class("InternalFunction")
function InternalFunction:initialize(body, wait)
    self.body = body
    self.wait = wait
end
function InternalFunction:execute(...)
    return self.body(...)
end
local stack = {}

function FUNCTIONSStackPush()
    table.insert(stack, table.copy(FUNCTIONS))
end

function FUNCTIONSStackPop()
    FUNCTIONS = table.remove(stack)
end

FUNCTIONS = {
    
    ["sin( number )"] = InternalFunction(function(value)
        return math.sin(math.rad(value))
    end, "number"),
    ["print( any )"] = InternalFunction(function(...)
        print(...)
        return nil
    end)
    
    
}

-- setmetatable(FUNCTIONS, {
--     __index = function(self, arg)
--         if not rawget(self, arg) then
--             throw("Unknown function: ".. tostring(arg), 1, true)
--         end
--         return rawget(self, arg)
--     end
-- })

