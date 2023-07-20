--@name Parser
--@author discord.gg/6Q5NnHQTrh // kekobka // STEAM_0:0:186583728
--@shared
--@include ./token.lua
local Token = require("./token.lua")


--@includedir ../ast/expressions/
requiredir("../ast/expressions/")

--@includedir ../ast/Statements/
requiredir("../ast/Statements/")
local TOKENTYPES = Token.types
local Parser = class("Parser")

function Parser:initialize(t)

    local EOF = Token(TOKENTYPES.EOF)
    local tokens = t
    local size = table.count(t)
    local pos = 1

    local function get(relativePosition)
        local position = pos + relativePosition

        if position > size then
            return EOF
        end

        return tokens[position]
    end

    local function consume(type)
        local curr = get(0)
        if type ~= curr.type then
            return throw("Token " .. tostring(curr) .. " doesn't match " .. type)
        end
        pos = pos + 1
        return curr
    end

    local function match(type)
        local curr = get(0)
        if type ~= curr.type then
            return false
        end
        pos = pos + 1
        return true
    end

    local function newFunction()
        local name = consume(TOKENTYPES.WORD).text
        consume(TOKENTYPES.LBRACKET)

        local expr = FunctionExpression(name)
        
        while not match(TOKENTYPES.RBRACKET) do
            local e = self:expression()
            expr:addArg(e)
            match(TOKENTYPES.COMMA)
        end
        return expr
    end    

    local function primary(v)

        local curr = get(0)

        if match(TOKENTYPES.NUMBER) then

            return ValueExpression(tonumber(curr.text), v)

        elseif get(0).type == TOKENTYPES.WORD and get(1).type == TOKENTYPES.LBRACKET then

            return newFunction()

        elseif match(TOKENTYPES.HEX_NUMBER) then

            return NumberExpression(tonumber("0x" .. curr.text), v)

        elseif match(TOKENTYPES.WORD) then

            return ConstantExpression(curr.text, v)

        elseif match(TOKENTYPES.TEXT) then
            return ValueExpression(curr.text, v)

        elseif match(TOKENTYPES.LBRACKET) then

            local r = self:expression(v)
            match(TOKENTYPES.RBRACKET)
            return r

        end

        return throw(curr.text .. "is not a ".. v)
    end

    local function unary(v)

        if match(TOKENTYPES.MINUS) then
            return UnaryExpression("-", primary(v))
        elseif match(TOKENTYPES.PLUS) then
            return primary(v)
        end
        return primary(v)
    end

    local function moduler(v)
        local expr = unary(v)

        while true do
            ::CONTINUE::
            if match(TOKENTYPES.FLEX) then
                expr = BinaryExpression("^", expr, unary(v))
                goto CONTINUE
            elseif match(TOKENTYPES.MODULE) then
                expr = BinaryExpression("%", expr, unary(v))
                goto CONTINUE
            end
            break
            
        end

        return expr
    end

    local function multi(v)
        local expr = moduler(v)

        while true do
            ::CONTINUE::
            if match(TOKENTYPES.STAR) then
                expr = BinaryExpression("*", expr, moduler(v))
                goto CONTINUE
            elseif match(TOKENTYPES.SLASH) then
                expr = BinaryExpression("/", expr, moduler(v))
                goto CONTINUE
            end
            break
            
        end

        return expr
    end

    local function additive(v)
        local expr = multi(v)

        while true do
            ::CONTINUE::
            if match(TOKENTYPES.PLUS) then
                expr = BinaryExpression("+", expr, multi(v))
                goto CONTINUE
            elseif match(TOKENTYPES.MINUS) then
                expr = BinaryExpression("-", expr, multi(v))
                goto CONTINUE
            end
            break
            
        end
        return expr
    end

    local function conditional(v)
        local expr = additive(v)

        while true do
            ::CONTINUE::
            if match(TOKENTYPES.GT) then
                expr = ConditionalExpression(">", expr, additive(v))
                goto CONTINUE
            elseif match(TOKENTYPES.GTEQ) then
                expr = ConditionalExpression(">=", expr, additive(v))
                goto CONTINUE
            elseif match(TOKENTYPES.LT) then
                expr = ConditionalExpression("<", expr, additive(v))
                goto CONTINUE
            elseif match(TOKENTYPES.LTEQ) then
                expr = ConditionalExpression("<=", expr, additive(v))
                goto CONTINUE
            end
            break
            
        end
        return expr
    end
    local function equality(v)
        local expr = conditional(v)
        if match(TOKENTYPES.EQEQ) then
            expr = ConditionalExpression("==", expr, conditional(v))
        elseif match(TOKENTYPES.EXCLEQ) then
            expr = ConditionalExpression("!=", expr, conditional(v))
        end
        return expr
    end
    local function logicalAnd(v)
        local expr = equality(v)
        while true do
            ::CONTINUE::
            if match(TOKENTYPES.AMPAMP) then
                expr = ConditionalExpression("&&", expr, equality(v))
                goto CONTINUE
            end
            if match(TOKENTYPES.AMP) then
                expr = ConditionalExpression("&", expr, equality(v))
                goto CONTINUE
            end
            break
        end
        return expr
    end
    local function logicalOr(v)
        local expr = logicalAnd(v)
        while true do
            ::CONTINUE::
            if match(TOKENTYPES.BARBAR) then
                expr = ConditionalExpression("||", expr, logicalAnd(v))
                goto CONTINUE
            end
            if match(TOKENTYPES.BAR) then
                expr = ConditionalExpression("|", expr, logicalAnd(v))
                goto CONTINUE
            end
            break
        end
        return expr
    end

    function self:expression(v)
        return logicalOr(v)
    end

    local function assignmentStatement()
        local curr = get(0)

        if match(TOKENTYPES.WORD) then
            local r = get(0).type
            local var = curr.text
            if r == TOKENTYPES.EQ then

                consume(TOKENTYPES.EQ)
                if not VariablesTypes[var] then
                    throw("Variable: ".. tostring(var) .. " is not defined", 1, true)
                end
                return AssignmentStatement(var, VariablesTypes[var], self:expression(), true)

            elseif r == TOKENTYPES.PLUSEQ then

                consume(TOKENTYPES.PLUSEQ)
                return AdditionStatement(var, self:expression())

            elseif r == TOKENTYPES.STAREQ then

                consume(TOKENTYPES.STAREQ)
                return StarStatement(var, self:expression())

            elseif r == TOKENTYPES.SLASHEQ then

                consume(TOKENTYPES.SLASHEQ)
                return SlashStatement(var, self:expression())

            elseif r == TOKENTYPES.PLUSPLUS then

                consume(TOKENTYPES.PLUSPLUS)
                return IncrementStatement(var)

            elseif r == TOKENTYPES.MINUSMINUS then

                consume(TOKENTYPES.MINUSMINUS)
                return DecrementStatement(var)

            elseif r == TOKENTYPES.MINUSEQ then
                
                consume(TOKENTYPES.MINUSEQ)
                return SubtractionStatement(var, self:expression())

            end
        elseif match(TOKENTYPES.KEYWORD) then
            local name = get(0)
            local type = curr.text
            if name.type == TOKENTYPES.WORD then
                consume(TOKENTYPES.WORD)
                consume(TOKENTYPES.EQ)
                return AssignmentStatement(name.text, type, self:expression(type))
            end
        end
        return throw("Unknown statement")
    end

    local function stateOrBlock()
        if get(0).type == TOKENTYPES.LBR then
            return self:block()
        end
        return self:statement()
    end

    local function IfElse()
        local condition = self:expression()
        local ifStatement = stateOrBlock()
        local elseStatement
        if match(TOKENTYPES.ELSE) then
            elseStatement = stateOrBlock()
        end

        return IfStatement(condition, ifStatement, elseStatement)

    end

    local function whileStatement()
        local condition = self:expression()
        local state = stateOrBlock()

        return WhileStatement(condition, state)
    end

    local function forStatement()
        local init = assignmentStatement()
        consume(TOKENTYPES.COMMA)
        local termination = self:expression()
        
        consume(TOKENTYPES.COMMA)
        local inc = assignmentStatement()
        local state = stateOrBlock()

        return ForStatement(init, termination, inc, state)
    end

    local function functionDefine()
        VariablesStackPush()
        local name = consume(TOKENTYPES.WORD).text
        consume(TOKENTYPES.LBRACKET)
        local argTypes = {}
        local argNames = {}

        while not match(TOKENTYPES.RBRACKET) do
            table.insert(argTypes, consume(TOKENTYPES.KEYWORD).text)
            table.insert(argNames, consume(TOKENTYPES.WORD).text)
            match(TOKENTYPES.COMMA)
        end
        local body = stateOrBlock()
        local res = FunctionDefineStatement(name, argTypes, argNames, body)
        VariablesStackPop()
        return res
    end

    function self:block()
        local block = Blockstatement()
        consume(TOKENTYPES.LBR)
        while not match(TOKENTYPES.RBR) do
            block:add(self:statement())
        end
        return block
    end

    function self:statement()

        if match(TOKENTYPES.PRINT) then
            return PrintStatement(self:expression())
        end
        if match(TOKENTYPES.IF) then
            return IfElse()
        end
        if match(TOKENTYPES.WHILE) then
            return whileStatement()
        end
        if match(TOKENTYPES.FOR) then
            return forStatement()
        end
        if match(TOKENTYPES.BREAK) then
            return BreakStatement()
        end
        if match(TOKENTYPES.CONTINUE) then
            return ContinueStatement()
        end
        
        if match(TOKENTYPES.DEF) then
            return functionDefine()
        end
        if get(0).type == TOKENTYPES.WORD and get(1).type == TOKENTYPES.LBRACKET then
            return FunctionStatement(newFunction())
        end

        return assignmentStatement()
    end

    function self:parse()
        local exps = Blockstatement()
        while not match(TOKENTYPES.EOF) do

            exps:add(self:statement())
        end
        return exps
    end

end

return Parser
