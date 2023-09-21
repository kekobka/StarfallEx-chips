NwSTACK = 0

local function GS(offset)
    return ("\t"):rep(NwSTACK + (offset or 0))
end
local CLASSVARIABLE = {}
Parser = class("Parser")
local TokenMeta = {
    __tostring = function(self)
        return ParseToken(self[1]) .. " " .. tostring(self[2] or "")
    end
}
local blockmeta = {
    __tostring = function(self)
        local ret = "\n"
        for _, token in next, self do
            ret = ret .. GS() .. tostring(token) .. "\n" -- ..  (token:endsWith(";") and "" or ";\n")
        end
        return ret
    end
}
---@param tokens table
function Parser:initialize(tokens, includes, name)
    self.TOKENS = tokens
    self.pos = 1
    self.length = table.count(self.TOKENS)
    self.includes = includes or {}
    self.name = name or "main"
    self.EOF = setmetatable({TOKENTYPES.EOF}, TokenMeta)
    self.PARSED = self:parse()
end

function Parser:__tostring()
    local ret = ""
    for _, token in next, self.PARSED do
        ret = ret .. tostring(token) .. "\n" -- ..  (token:endsWith(";") and "" or ";\n")
    end
    return ret
end
---@param relpos number
function Parser:get(relpos)
    local position = self.pos + relpos

    if position > self.length then
        return self.EOF
    end

    return self.TOKENS[position]
end

--- func возвращает true и pos++ если TokenType равен текущему токену
---@param TokenType TOKENTYPES
---@return boolean
function Parser:match(TokenType)
    if TokenType == self:get(0)[1] then
        self.pos = self.pos + 1
        return true
    end

    return false
end

--- func возвращает Token и pos++ если TokenType равен текущему токену
---@param TokenType TOKENTYPES
---@return Token
function Parser:consume(type)
    local curr = self:get(0)
    if type ~= curr[1] then
        return throw("Token " .. self.pos .. ": " .. tostring(curr) .. " doesn't match " .. ParseToken(type))
    end
    self.pos = self.pos + 1
    return curr
end
function Parser:block()
    local block = {}
    self:consume(TOKENTYPES.LBR)
    NwSTACK = NwSTACK + 1
    while not self:match(TOKENTYPES.RBR) and not self:match(TOKENTYPES.EOF) do
        local s = self:statement()
        table.insert(block, s)
    end
    local t = tostring(setmetatable(block, blockmeta))
    NwSTACK = NwSTACK - 1
    return t
end
function Parser:stateOrBlock()
    if self:get(0)[1] == TOKENTYPES.LBR then
        return self:block()
    end
    return "\n\t" .. tostring(self:statement()) .. "\n"
end
function Parser:getFString(left, center)
    local fstring = '"' .. tostring(left) .. '" .. (' .. center .. ") "

    while self:get(0)[1] == TOKENTYPES.STRING do
        local left = self:consume(TOKENTYPES.STRING)[2]

        local center = self:expression()
        self:consume(TOKENTYPES.RBR)

        local ret = ""
        if self:match(TOKENTYPES.FSTRING) then
            fstring = fstring .. '.. ' .. self:getFString(left, center)
        else
            local right = self:consume(TOKENTYPES.STRING)[2]
            return fstring .. ' .."' .. tostring(left) .. '" .. (' .. center .. ') .. "' .. tostring(right) .. '"'
        end
    end
    return fstring
end
function Parser:parse()
    local exps = {} -- self:Blockstatement()
    while not self:match(TOKENTYPES.EOF) do
        local s, t = self:statement()
        table.insert(exps, s)
    end
    return exps
end

function Parser:statement()
    if self:match(TOKENTYPES.EOF) then
        return
    end
    
    if self:match(TOKENTYPES.CLASSDEF) then
        return self:classDefine()
    end
    if self:get(0)[1] == TOKENTYPES.WORD and self:get(1)[1] == TOKENTYPES.LBRACKET then
        return self:newFunction()
    end
    if self:match(TOKENTYPES.FUNCTION) then
        return self:defineFunction()
    end
    if self:match(TOKENTYPES.STATIC) then
        return self:defineFunction(self:match(TOKENTYPES.ASYNC))
    end

    if self:match(TOKENTYPES.IF) then
        return self:ifelse()
    end
    if self:match(TOKENTYPES.FOR) then
        return self:forStatement()
    end
    if self:match(TOKENTYPES.WHILE) then
        return self:whileStatement()
    end

    if self:match(TOKENTYPES.EXPORT) then
        return "return " .. tostring(self:expression())
    end
    if self:match(TOKENTYPES.BREAK) then
        return "break"
    end
    if self:match(TOKENTYPES.CONTINUE) then
        return "continue"
    end
    if self:match(TOKENTYPES.ASYNC) then
        self:match(TOKENTYPES.FUNCTION)
        return self:newFunction(true)
    end
    if self:match(TOKENTYPES.AWAIT) then
        return "local _ = await* " .. self:statement() --.. ")"
    end
    if self:match(TOKENTYPES.RETURN) then
        return "return " .. tostring(self:expression())
    end

    if self:match(TOKENTYPES.IMPORT) then

        local WTF = self:match(TOKENTYPES.LBR)
        local center = {self:consume(TOKENTYPES.WORD)[2]}
        while WTF and self:match(TOKENTYPES.COMMA) do
            table.insert(center, self:consume(TOKENTYPES.WORD)[2])
        end
        if WTF then
            self:consume(TOKENTYPES.RBR)
        end

        self:consume(TOKENTYPES.WORD) -- from KEYWORD

        local from = self:consume(TOKENTYPES.STRING)[2]

        if self.includes[self.name] == from then
            return throw("cyclic import")
        end
        local concated = table.concat(center, ", ")
        self.includes[from] = self.name
        local f = file.find(from .. ".js")
        local toks = Tokenizer(file.read(f[1]))
        NwSTACK = NwSTACK + 1
        local cc = blockmeta.__tostring(Parser(toks.TOKENS, self.includes, from).PARSED)
        local code = "(function()" .. tostring(cc) .. GS() .. "end)()"
        local shifr = "_INCLUDE_"

        local t = {}
        for i, v in next, center do
            t[i] = shifr .. "." .. v
        end
        local init = "do\n" .. GS() .. "local ".. shifr .. " = " .. code .. "\n" .. GS() .. concated .. " = " .. table.concat(t, ", ") .. "\nend"
        NwSTACK = NwSTACK - 1
        return "local " .. concated .. "\n" .. init
    end
    return self:AssignmentStatement()
end

function Parser:ifelse()
    local condition = self:expression()
    local ifStatement = self:stateOrBlock()
    local elseStatement
    if self:match(TOKENTYPES.ELSE) then
        elseStatement = self:stateOrBlock()
        return "if " .. tostring(condition) .. " then " .. tostring(ifStatement) .. GS() .. "else " .. tostring(elseStatement) .. GS() .. "end"
    else
        return "if " .. tostring(condition) .. " then " .. tostring(ifStatement) .. GS() .. "end"
    end
end
function Parser:AssignmentStatement()
    local init
    if self:match(TOKENTYPES.VAR) then
        init = true
    end
    local curr = self:get(0)

    if self:match(TOKENTYPES.WORD) then
        local r = self:get(0)[1]
        if r == TOKENTYPES.EQ then

            self:consume(TOKENTYPES.EQ)
            
            if self:match(TOKENTYPES.CLASSNEW) then
                CLASSVARIABLE[curr[2]] = curr
            else
                CLASSVARIABLE[curr[2]] = nil
            end
            local expr = {}
            table.insert(expr, self:expression())
            return (init and "local " or "") .. tostring(curr[2]) .. " = " .. table.concat(expr, ", ")

        elseif r == TOKENTYPES.PLUSEQ then

            self:consume(TOKENTYPES.PLUSEQ)

            local expr, type = self:expression(var)
            return self:ParseAssignment(TOKENTYPES.PLUSEQ, var, expr, type, init)

        elseif r == TOKENTYPES.STAREQ then

            self:consume(TOKENTYPES.STAREQ)
            local expr, type = self:expression(var)
            return self:ParseAssignment(TOKENTYPES.STAREQ, var, expr, type, init)

        elseif self:match(TOKENTYPES.POINTER) then
            local expr, type = self:expression(var)

            return self:ParseAssignment(TOKENTYPES.POINTER, var, expr, type, init)
            -- return ":".. self:expression(), TOKENTYPES.POINTER

        elseif r == TOKENTYPES.SLASHEQ then

            self:consume(TOKENTYPES.SLASHEQ)
            local expr, type = self:expression(var)
            return self:ParseAssignment(TOKENTYPES.SLASHEQ, var, expr, type, init)

        elseif r == TOKENTYPES.PLUSPLUS then

            self:consume(TOKENTYPES.PLUSPLUS)

            return self:ParseAssignment(TOKENTYPES.PLUSPLUS, var, nil, nil, init)

        elseif r == TOKENTYPES.MINUSMINUS then

            self:consume(TOKENTYPES.MINUSMINUS)
            return self:ParseAssignment(TOKENTYPES.MINUSMINUS, var, nil, nil, init)

        elseif r == TOKENTYPES.MINUSEQ then

            self:consume(TOKENTYPES.MINUSEQ)
            local expr, type = self:expression(var)
            return self:ParseAssignment(TOKENTYPES.MINUSEQ, var, expr, type, init)
        elseif self:match(TOKENTYPES.POINT) then
            if CLASSVARIABLE[curr[2]] then
                local e = self:statement()
                if string.endsWith(e,")") then -- string.sub(e, -1) == ")" 
                    return tostring(curr[2]) .. ":" .. e
                end
                return tostring(curr[2]) .. "." .. e
            end
            return tostring(curr[2]) .. "." .. self:statement()
        elseif self:match(TOKENTYPES.KEYKARD) then
            return tostring(curr[2]) .. ":" .. self:statement()
        elseif self:match(TOKENTYPES.OPENTBL) then
            local eprv = self:expression()
            self:consume(TOKENTYPES.CLOSETBL) 
            self:consume(TOKENTYPES.EQ) 
            
            if self:match(TOKENTYPES.CLASSNEW) then
                CLASSVARIABLE[curr[2]] = curr
            else
                CLASSVARIABLE[curr[2]] = nil
            end
            local expr = {}
            table.insert(expr, self:expression())
            return tostring(curr[2]) .. "[" .. eprv .. "]" .. " = " .. table.concat(expr, ", ")
        elseif self:match(TOKENTYPES.COMMA) then
            return tostring(curr[2]) .. ", " .. tostring(self:statement())
        end
    elseif self:match(TOKENTYPES.LBR) then
        local center = {self:consume(TOKENTYPES.WORD)[2]}
        while self:match(TOKENTYPES.COMMA) do
            table.insert(center, self:consume(TOKENTYPES.WORD)[2])
        end
        self:consume(TOKENTYPES.RBR)
        self:consume(TOKENTYPES.EQ)
        local concated = table.concat(center, ", ")
        local Local = (init and "local " or "") .. concated
        NwSTACK = NwSTACK + 1
        local expr = self:expression()
        
        local t = {}
        for i, v in next, center do
            t[i] = "L" .. "." .. v
        end

        local cc = "do\n" .. GS() .. "local L = " .. expr .. "\n" .. GS() .. concated .. " = " .. table.concat(t, ", ") .. "\n" .. GS(-1) .. "end"
        NwSTACK = NwSTACK - 1
        return Local .. "\n" .. GS() .. cc

    elseif self:match(TOKENTYPES.ENDBLOCK) then
        return ""
    end
    return throw("Unknown statement " .. self.pos .. ": " .. tostring(curr))
end

function Parser:expression()
    return self:logicalOr()
end
function Parser:logicalOr(var)
    local expr = self:logicalAnd(var)
    while true do
        ::CONTINUE::
        if self:match(TOKENTYPES.BARBAR) then
            expr = tostring(expr) .. " || " .. tostring(self:logicalAnd(var))
            goto CONTINUE
        end
        if self:match(TOKENTYPES.BAR) then
            expr = tostring(expr) .. " | " .. tostring(self:logicalAnd(var))
            goto CONTINUE
        end
        break
    end

    return expr
end

function Parser:logicalAnd(var)
    local expr = self:equality(var)
    while true do
        ::CONTINUE::
        if self:match(TOKENTYPES.AMPAMP) then
            expr = tostring(expr) .. " && " .. tostring(self:equality(var))
            goto CONTINUE
        end
        if self:match(TOKENTYPES.AMP) then
            expr = tostring(expr) .. " & " .. tostring(self:equality(var))
            goto CONTINUE
        end
        break
    end
    return expr
end

function Parser:equality(var)
    local expr = self:conditional(var)
    if self:match(TOKENTYPES.EQEQ) then
        local expr2 = self:conditional(var)
        expr = tostring(expr) .. " == " .. tostring(expr2)
    elseif self:match(TOKENTYPES.EXCLEQ) then
        local expr2 = self:conditional(var)
        expr = tostring(expr) .. " ~= " .. tostring(expr2)
    end
    return expr
end

function Parser:conditional(var)
    local expr = self:additive(var)

    while true do
        ::CONTINUE::
        if self:match(TOKENTYPES.GT) then
            local expr2 = self:additive(var)
            expr = tostring(expr) .. " > " .. tostring(expr2)
            goto CONTINUE
        elseif self:match(TOKENTYPES.GTEQ) then
            local expr2 = self:additive(var)
            expr = tostring(expr) .. " >= " .. tostring(expr2)
            goto CONTINUE
        elseif self:match(TOKENTYPES.LT) then
            local expr2 = self:additive(var)
            expr = tostring(expr) .. " < " .. tostring(expr2)
            goto CONTINUE
        elseif self:match(TOKENTYPES.LTEQ) then
            local expr2 = self:additive(var)
            expr = tostring(expr) .. " <= " .. tostring(expr2)
            goto CONTINUE
        end
        break

    end
    return expr
end

function Parser:additive(var)
    local expr = self:multi(var)

    while true do
        ::CONTINUE::
        if self:match(TOKENTYPES.PLUS) then
            local expr2 = self:multi(var)
            expr = tostring(expr) .. " + " .. tostring(expr2)
            goto CONTINUE
        elseif self:match(TOKENTYPES.MINUS) then
            local expr2 = self:multi(var)
            expr = tostring(expr) .. " - " .. tostring(expr2)
            goto CONTINUE
        end
        break

    end
    return expr
end

function Parser:multi(var)
    local expr = self:moduler(var)

    while true do
        ::CONTINUE::
        if self:match(TOKENTYPES.STAR) then
            local expr2 = self:moduler(var)
            expr = tostring(expr) .. (" * ") .. tostring(expr2)
            goto CONTINUE
        elseif self:match(TOKENTYPES.SLASH) then
            local expr2 = self:moduler(var)
            expr = tostring(expr) .. (" / ") .. tostring(expr2)
            goto CONTINUE
        end
        break

    end

    return expr
end

function Parser:moduler(var)
    local expr = self:unary(var)

    while true do
        ::CONTINUE::
        if self:match(TOKENTYPES.FLEX) then
            local expr2 = self:unary(var)
            expr = tostring(expr) .. (" ^ ") .. tostring(expr2)
            goto CONTINUE
        elseif self:match(TOKENTYPES.MODULE) then
            local expr2 = self:unary(var)
            expr = tostring(expr) .. (" % ") .. tostring(expr2)
            goto CONTINUE
        elseif self:match(TOKENTYPES.CONCAT) then
            local expr2 = self:unary(var)
            expr = tostring(expr) .. (" .. ") .. tostring(expr2)
        end
        break

    end

    return expr
end

function Parser:unary(var)

    if self:match(TOKENTYPES.MINUS) then
        local expr = self:primary(var)
        return "-" .. tostring(expr)
    elseif self:match(TOKENTYPES.EXCL) then
        local expr = self:primary(var)
        return " not " .. tostring(expr)
    elseif self:match(TOKENTYPES.PLUS) then
        return self:primary(var)
    end
    return self:primary(var)
end

function Parser:primary(var)

    local curr = self:get(0)

    if self:match(TOKENTYPES.NUMBER) or self:match(TOKENTYPES.HEX) then
        return tostring(curr[2])
    elseif self:match(TOKENTYPES.STRING) then
        return '"' .. tostring(curr[2]) .. '"'
    elseif self:match(TOKENTYPES.LBR) then
        local start = self:expression()
        if not start then
            self:consume(TOKENTYPES.RBR)
            return "{}"
        end
        local fin = start 
        
        if self:match(TOKENTYPES.KEYKARD) then
            try(function()
                fin = self:expression()
            end)
        end
        local center = {'["' .. start .. '"] = ' .. fin}

        while self:match(TOKENTYPES.COMMA) do
            local a = tostring(self:expression())
            local b = a
            
            if self:match(TOKENTYPES.KEYKARD) then
                b = self:expression()
            end
            table.insert(center, '["' .. a .. '"] = ' .. b)
        end
        self:consume(TOKENTYPES.RBR)
        return '{ ' .. table.concat(center, ", ") .. ' }'
    elseif self:get(0)[1] == TOKENTYPES.WORD then

        if self:get(1)[1] == TOKENTYPES.LBRACKET then
            local r = {self:newFunction(self:match(TOKENTYPES.ASYNC))}
            while self:match(TOKENTYPES.POINT) do
                table.insert(r,self:newFunction(self:match(TOKENTYPES.ASYNC)))
            end
            return table.concat(r, ":")
        end
        self:consume(TOKENTYPES.WORD)
        if self:match(TOKENTYPES.LAMBDA) then
            return "function( " .. tostring(curr[2]) .. " )" .. tostring(self:stateOrBlock()) .. GS() .. "end"
        end
        if self:match(TOKENTYPES.POINT) then
            if CLASSVARIABLE[curr[2]] then
                return tostring(curr[2]) .. ":" .. self:expression()
            end
            return tostring(curr[2]) .. "." .. self:expression()
        end
        if self:match(TOKENTYPES.OPENTBL) then
            local ret = tostring(curr[2]) .. "[" .. self:expression() .. "]"
            self:consume(TOKENTYPES.CLOSETBL)
            return ret
        end
        return tostring(curr[2])
    elseif self:match(TOKENTYPES.FSTRING) then

        local left = self:consume(TOKENTYPES.STRING)[2]
        local center = self:expression()
        self:consume(TOKENTYPES.RBR)
        local ret = ""
        if self:match(TOKENTYPES.FSTRING) then
            ret = self:getFString(left, center)
        else
            local right = self:consume(TOKENTYPES.STRING)[2]
            ret = '"' .. tostring(left) .. '" .. (' .. center .. ') .. "' .. tostring(right) .. '"'
        end
        return ret

    elseif self:match(TOKENTYPES.LBRACKET) then
        local expr = {}
        
        if self:get(0)[1] ~= TOKENTYPES.RBRACKET then
            table.insert(expr, self:expression())
            while self:match(TOKENTYPES.COMMA) do
                table.insert(expr, self:expression())
            end
        end
        
        self:match(TOKENTYPES.RBRACKET)
        
        if self:match(TOKENTYPES.LAMBDA) then
            return "function( " .. table.concat(expr,", ") .. " )" .. tostring(self:stateOrBlock()) .. GS() .. "end"
        end
        if self:get(0)[1] == TOKENTYPES.LBRACKET then
            return "( " .. table.concat(expr,", ") .. " )" .. self:expression()
        end
        return "( " .. table.concat(expr,", ") .. " )"
    elseif self:match(TOKENTYPES.ASYNC) then
        return "async* " .. self:expression() -- .. " )"
    elseif self:match(TOKENTYPES.AWAIT) then
        return "await* " .. self:expression() -- .. " )"
    elseif self:match(TOKENTYPES.CLASSNEW) then

        return self:expression()
    end
    -- return throw("Unknown expression " .. self.pos .. ": " .. tostring(curr))
end
-- local lambda = self:get(0)[1] == TOKENTYPES.COMMA
-- if lambda then
--     while self:match(TOKENTYPES.COMMA) do
--         table.insert(expr, self:consume(TOKENTYPES.WORD)[2])
--     end
--     self:consume(TOKENTYPES.RBRACKET)
--     self:consume(TOKENTYPES.LAMBDA)
--     local ll = tostring(self:stateOrBlock())
--     return (init and "local " or "") .. tostring(curr[2]) .. " = " .. "function( " .. table.concat(expr, ", ") .. ")" .. ll .. GS() .. "\nend"
-- end
function Parser:newFunction(async)

    local name = self:consume(TOKENTYPES.WORD)[2]
    self:consume(TOKENTYPES.LBRACKET)

    local args = {}
    while not self:match(TOKENTYPES.RBRACKET) do
        local e = self:expression()
        table.insert(args, tostring(e))
        self:match(TOKENTYPES.COMMA)
    end

    if self:get(0)[1] == TOKENTYPES.LBR then

        local body = self:stateOrBlock()
        table.insert(args, 1, "self")
        return tostring(name) .. " = " .. (async and "async* " or "") .. "function " .. "( " .. table.concat(args, ", ") .. " )\n" .. tostring(body) .. GS() .. "end" --.. (async and ")" or "") 
    end
    return tostring(name) .. "( " .. table.concat(args, ", ") .. " )"
end
function Parser:defineFunction(async)

    local name = self:consume(TOKENTYPES.WORD)[2]
    self:consume(TOKENTYPES.LBRACKET)
    local argNames = {}
    while not self:match(TOKENTYPES.RBRACKET) do
        table.insert(argNames, self:consume(TOKENTYPES.WORD)[2])
        self:match(TOKENTYPES.COMMA)
    end

    local body = self:stateOrBlock()

    local res = tostring(name) .. " = " .. (async and "async* " or "") .. "function " .. "( " .. table.concat(argNames, ", ") .. " )\n" .. tostring(body) .. GS() .. "end" --.. (async and ")" or "") 

    return res
end
function Parser:forStatement()

    self:consume(TOKENTYPES.LBRACKET)

    local init = self:AssignmentStatement()
    
    self:consume(TOKENTYPES.ENDBLOCK)

    local termination = self:expression()
    self:consume(TOKENTYPES.ENDBLOCK)

    local inc = self:expression()
    self:consume(TOKENTYPES.RBRACKET)

    local state = self:stateOrBlock()

    return "for " .. init .. ", " .. termination .. ", " .. inc .. " do" .. tostring(state) .. GS() .. "end"
end
function Parser:whileStatement()
    local condition = self:expression()
    local state = self:stateOrBlock()

    return "while " .. tostring(condition) .. " do " .. tostring(state) .. GS() .. "end"
end

function Parser:classDefine()
    local classname = self:consume(TOKENTYPES.WORD)[2]
    local block = setmetatable({}, blockmeta)
    local values = setmetatable({}, {
        __tostring = function(self)
            local ret = "\n"
            for _, token in next, self do
                ret = ret .. GS() .. tostring(token) .. ",\n" -- ..  (token:endsWith(";") and "" or ";\n")
            end
            return ret
        end
    })
    NwSTACK = NwSTACK + 1
    local constructor = "__init = function( self ) end"
    
    local extends
    if self:match(TOKENTYPES.EXTENDS) then
        extends = self:consume(TOKENTYPES.WORD)
    end
    self:consume(TOKENTYPES.LBR)
    while not self:match(TOKENTYPES.RBR) do
        
        local a
        if self:match(TOKENTYPES.CLASSCONSTRUCTOR) then
            self:consume(TOKENTYPES.LBRACKET)
            local argNames = { "self" }
            while not self:match(TOKENTYPES.RBRACKET) do
                table.insert(argNames, self:consume(TOKENTYPES.WORD)[2])
                self:match(TOKENTYPES.COMMA)
            end
        
            local body = self:stateOrBlock()
        
            constructor = "__init = function " .. "( " .. table.concat(argNames, ", ") .. " )\n" .. tostring(body) .. GS(1) .. "end"
        
            goto CONTINUE
        end
        a = self:statement()
        if a ~= "" then
            table.insert(values, a)
        end
        ::CONTINUE::
    end
    local a = "local " .. classname .. '\n' .. 'do\n' .. '\tlocal _class_0\n' .. '\tlocal _base_0 = { ' .. tostring(values) .. GS(0) .. '}\n' .. '\t_base_0.__index = _base_0\n' .. '\t_class_0 = setmetatable({\n' .. '\t\t' .. constructor .. ',\n' .. '\t\t__base = _base_0,\n' .. '\t\t__name = "' .. classname .. '"\n' .. '\t}, {\n' .. '\t\t__index = _base_0,\n' .. '\t__call = function(cls, ...)\n' .. '\t\tlocal _self_0 = setmetatable({}, _base_0) \n' .. '\t\tcls.__init(_self_0, ...) \n' .. '\t\treturn _self_0\n' .. '\tend\n' .. '\t})\n' .. '\t_base_0.__class = _class_0\n' .. '\t' .. classname .. ' = _class_0\n' .. 'end'
    NwSTACK = NwSTACK - 1
    -- return (not EXPORT and "local " or "") .. classname .. " \ndo" .. tostring(block) .. "end"
    return a

end
