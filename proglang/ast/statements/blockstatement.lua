--@name Blockstatement

--@include ./Statement.lua

local Statement = require("./Statement.lua")
Blockstatement = class("Blockstatement", Statement)

function Blockstatement:initialize(state)
    self.state = state or {}

end

function Blockstatement:execute()

    for _,s in next, self.state do
        s:execute()
    end
end
function Blockstatement:add(state)
    table.insert(self.state, state)
end
function Blockstatement:accept(v)
    for _,s in next, self.state do
        s:accept(v)
    end
    
end
function Blockstatement:__tostring()
    local result = ""
    for _,s in next, self.state do
        result = result .. tostring(s) .. "\n"
    end
    return result
end


