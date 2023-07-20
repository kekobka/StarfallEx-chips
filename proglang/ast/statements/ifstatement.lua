--@name IfStatement
--@author discord.gg/6Q5NnHQTrh // kekobka // STEAM_0:0:186583728
--@shared

--@include ./Statement.lua

local Statement = require("./Statement.lua")

IfStatement = class("IfStatement", Statement)


function IfStatement:initialize(ex, st1, st2)
    self.ex = ex
    self.st1 = st1
    self.st2 = st2
end


function IfStatement:execute()
    local result = self.ex:eval()
    if result then
        self.st1:execute()
    elseif self.st2 then
        self.st2:execute()
    end
end

function IfStatement:__tostring()
    return "if "..tostring(self.ex).." "..tostring(self.st1).." "..(self.st2 and "\nelse " .. tostring(self.st2))
end

