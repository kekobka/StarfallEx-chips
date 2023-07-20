--@name ForStatement
--@include ./Statement.lua

local Statement = require("./Statement.lua")
ForStatement = class("ForStatement", Statement)


function ForStatement:initialize(init, terminate, inc, block)
    self.init = init
    self.terminate = terminate
    self.inc = inc
    self.block = block
end

function ForStatement:execute()

    self.init:execute()
    while self.terminate:eval() do
        local b
        xpcall(self.block.execute, function(state)
            b = state.message
        end, self.block)
        if tostring(b) == "continue" then self.inc:execute() goto CONTINUE end
        if tostring(b) == "break" then break end
        self.inc:execute()
        ::CONTINUE::
    end
    
end

function ForStatement:__tostring()

    return "for (" .. tostring(self.init) .. ", " .. tostring(self.terminate) .. ", " .. tostring(self.inc) .. ") { \n\t" .. tostring(self.block) .. "}"
end