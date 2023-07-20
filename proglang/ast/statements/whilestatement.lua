--@name WhileStatement

--@include ./Statement.lua

local Statement = require("./Statement.lua")

WhileStatement = class("WhileStatement", Statement)


function WhileStatement:initialize(cond, block)
    self.cond = cond
    self.block = block
end

function WhileStatement:execute()
    while self.cond:eval() do
        local b
        xpcall(self.block.execute, function(state)
            b = state.message
        end, self.block)
        if tostring(b) == "continue" then goto CONTINUE end
        if tostring(b) == "break" then break end
        ::CONTINUE::
    end
    
end

function WhileStatement:__tostring()

    return "while" .. tostring(self.cond) .. " " .. tostring(self.state)
end
