--@name FUNCTIONS
local InternalFunction = class("InternalFunction")
function InternalFunction:initialize(body)
    self.body = body
end
function InternalFunction:execute(...)
    self.body(...)
end

FUNCTIONS = {
    
    ["sin( number )"] = InternalFunction(function(value)
        if not isnumber(value) then
            return throw(tostring(value).." is not a number", 3, true)
        end
        return math.sin(math.rad(value))
    end),
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

