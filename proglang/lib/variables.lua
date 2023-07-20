--@name Variables

Variables = {
    ["PI"] = math.pi,
}
VariablesTypes = {
    ["PI"] = "num",
}

local stack = {}

function VariablesStackPush()
    table.insert(stack, table.copy(Variables))
    table.insert(stack, table.copy(VariablesTypes))
end

function VariablesStackPop()
    VariablesTypes = table.remove(stack)
    Variables = table.remove(stack)
end

Variables = setmetatable(Variables, {
    __index = function(self, arg)
        local get = rawget(self, arg)
        if not get then
            throw("Unknown variable: ".. tostring(arg), 1, true)
        end
        return get
    end
})
-- VariablesTypes = setmetatable(VariablesTypes, {
--     __index = function(self, arg)
--         local get = rawget(self, arg)
--         if get ~= nil then
--             throw("Variable: ".. tostring(arg) .. " as " .. get .." alredy exists", 1, true)
--         end
--         return get
--     end,
--     __newindex = function(self, arg, type)
--         if rawget(self, arg) ~= nil then
--             throw("Variable: ".. tostring(arg) .. " as " .. tostring(type) .." alredy exists", 1, true)
--         end
--         return rawset(self, arg, type)
--     end
-- })
