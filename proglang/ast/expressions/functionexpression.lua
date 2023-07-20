--@name FunctionExpression

--@include ./expression.lua

local Expression = require("./expression.lua")
FunctionExpression = class("FunctionExpression", Expression)


function FunctionExpression:initialize(name, args)
    self.args = args or {}
    self.name = name
end


function FunctionExpression:addArg(arg)
    table.insert(self.args, arg)
end
function FunctionExpression:eval()
    local values = {}
    local types = {}
    for _, arg in next, self.args do
        table.insert(values, arg:eval())
        
        table.insert(types, tostring(arg.type))
    end
    
    local fn = FUNCTIONS[self.name.."( "..table.concat(types,", ").." )"]

    if not fn then
        fn = FUNCTIONS[self.name.."( any )"]
    end
    if not fn then
        return throw("Unknown function: ".. tostring(self.name.."( "..table.concat(types,", ").." )"), 1, true)
    end

    if fn.custom then
        VariablesStackPush()
        for i = 1, #types do
            
            Variables[fn.args[i]] = values[i]
        end
        local result = fn:execute()
        VariablesStackPop()
        return result
    end
    
    return fn:execute(unpack(values))
end

function FunctionExpression:__tostring()
    local args = ""
    for k, v in next, self.args do
        args = args .. tostring(v)
    end
    return "fn: "..self.name.."( ".. args .. " )"
end


