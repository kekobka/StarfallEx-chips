Parser = class("Parser")

local NwSTACK = 0

local function GetStack(offset)
    return ("\t"):rep(NwSTACK + (offset or 0))
end

function Parser:initialize(tokens)
    self.TOKENS = tokens
    self.pos = 1
    self.length = table.count(self.TOKENS)

    self.EOF = {TOKENTYPES.EOF}
    self.PARSED = self:parse()
end
function Parser:__tostring()
    local ret = ""
    for _, token in next, self.PARSED do
        ret = ret .. tostring(token) .. ";\n"
    end
    return ret
end
function Parser:parse()
    local exps = {} -- self:Blockstatement()
    while not self:match(TOKENTYPES.EOF) do
        local s, t = self:statement()
        table.insert(exps, s)
    end
    return exps
end

function Parser:get(relpos)
    local position = self.pos + relpos

    if position > self.length then
        return self.EOF
    end

    return self.TOKENS[position]
end

function Parser:match(TokenType)
    if TokenType == self:get(0)[1] then
        self.pos = self.pos + 1
        return true
    end

    return false
end
function Parser:consume(type)
    local curr = self:get(0)
    if type ~= curr[1] then
        return throw("Token " .. self.pos .. ": " .. tostring(curr) .. " doesn't match " .. ParseToken(type))
    end
    self.pos = self.pos + 1
    return curr
end

function Parser:statement(EXPORT, Relative)

    if self:match(TOKENTYPES.IF) then
        return self:_IfElse()
    end
    if self:match(TOKENTYPES.WHILE) then
        return self:_WhileStatement()
    end
    if self:match(TOKENTYPES.FOR) then
        return self:_ForStatement()
    end
    if self:match(TOKENTYPES.BREAK) then
        return "break"
    end
    if self:match(TOKENTYPES.CONTINUE) then
        return "continue"
    end
    if self:match(TOKENTYPES.RETURN) then

        return "return " .. self:expression()
    end
    if self:match(TOKENTYPES.FSTRING) then
        return self:expression()
    end
    if self:match(TOKENTYPES.FUNCTION) then
        return self:_FunctionDefine(EXPORT, Relative), TOKENTYPES.EQ
    end
    if self:match(TOKENTYPES.CLASSDEF) then
        return self:_ClassDefine(EXPORT)
    end
    if self:get(0)[1] == TOKENTYPES.WORD and self:get(1)[1] == TOKENTYPES.LBRACKET then
        return self:_NewFunction(EXPORT)
    end
    if self:match(TOKENTYPES.EXPORT) then
        return self:statement(true)
    end
    if self:match(TOKENTYPES.CLASSCONSTRUCTOR) then
        return self:_NewConstructorDefine(EXPORT, Relative), TOKENTYPES.CLASSCONSTRUCTOR
    end

    return self:AssignmentStatement(nil, EXPORT)
end

function Parser:_FunctionDefine(EXPORT, Relative)
    VARIABLESPUSH()
    local name = self:consume(TOKENTYPES.WORD)[2]
    self:consume(TOKENTYPES.LBRACKET)
    local argNames = {}
    if Relative then
        table.insert(argNames, "self")
    end
    while not self:match(TOKENTYPES.RBRACKET) do
        table.insert(argNames, self:consume(TOKENTYPES.WORD)[2])
        self:match(TOKENTYPES.COMMA)
    end

    local body = self:stateOrBlock()

    local res = (not EXPORT and "local " or "") .. tostring(name) .. " = function " .. "( " .. table.concat(argNames, ", ") .. " )\n" .. tostring(body) .. GetStack() .. "end"
    VARIABLESPOP()
    return res
end

local ConstructorDefinemeta = {
    __tostring = function(self)
        local ret = "\n"
        for _, token in next, self do
            ret = ret .. GetStack(1) .. "self." .. tostring(token) .. ";\n"
        end
        return ret
    end
}

function Parser:_NewConstructorDefine(EXPORT, Relative)
    VARIABLESPUSH()

    self:consume(TOKENTYPES.LBRACKET)
    local argNames = {}

    while not self:match(TOKENTYPES.RBRACKET) do
        table.insert(argNames, self:consume(TOKENTYPES.WORD)[2])
        self:match(TOKENTYPES.COMMA)
    end

    local body = self:stateOrBlock(EXPORT, Relative)
    body = setmetatable(body, ConstructorDefinemeta)
    local res = "__init = function " .. "( self, " .. table.concat(argNames, ", ") .. " )\n" .. tostring(body) .. GetStack() .. "end"
    VARIABLESPOP()
    return res
end

function Parser:_LAMBDAFunctionDefine(name, argNames, EXPORT)
    VARIABLESPUSH()

    local body = self:stateOrBlock()
    local res = name .. " function " .. tostring(name) .. "( " .. table.concat(argNames, ", ") .. " )\n" .. tostring(body) .. GetStack() .. "end"
    VARIABLESPOP()
    return res
end
local blockmeta = {
    __tostring = function(self)
        local ret = "\n"
        for _, token in next, self do
            ret = ret .. GetStack(1) .. tostring(token) .. ";\n"
        end
        return ret
    end
}

function Parser:_ClassDefine(EXPORT)
    local classname = self:consume(TOKENTYPES.WORD)[2]
    local block = setmetatable({}, blockmeta)
    local values = setmetatable({}, blockmeta)
    NwSTACK = NwSTACK + 1
    local constructor = "__init = function() end"
    VARIABLESPUSH()
    self:consume(TOKENTYPES.LBR)
    while not self:match(TOKENTYPES.RBR) do
        local a, isValue = self:statement(true, true)
        if isValue == TOKENTYPES.EQ then
            table.insert(values, a)
        elseif isValue == TOKENTYPES.CLASSCONSTRUCTOR then
            constructor = a
        else
            table.insert(block, a)
        end
    end
    VARIABLESPOP()
    local a = (not EXPORT and "local " .. classname .. '\n' or "") .. 'do\n' .. '\tlocal _class_0\n' .. '\tlocal _base_0 = { ' .. tostring(values) .. GetStack(0) .. '}\n' .. '\t_base_0.__index = _base_0\n' .. '\t_class_0 = setmetatable({\n' .. '\t\t' .. constructor .. ',\n' .. '\t\t__base = _base_0,\n' .. '\t\t__name = "' .. classname .. '"\n' .. '\t}, {\n' .. '\t\t__index = _base_0,\n' .. '\t__call = function(cls, ...)\n' .. '\t\tlocal _self_0 = setmetatable({}, _base_0) \n' .. '\t\tcls.__init(_self_0, ...) \n' .. '\t\treturn _self_0\n' .. '\tend\n' .. '\t})\n' .. '\t_base_0.__class = _class_0\n' .. '\t' .. classname .. ' = _class_0\n' .. 'end'
    NwSTACK = NwSTACK - 1
    -- return (not EXPORT and "local " or "") .. classname .. " \ndo" .. tostring(block) .. "end"
    return a

end
function Parser:block(EXPORT, Relative)
    local block = {}
    NwSTACK = NwSTACK + 1
    VARIABLESPUSH()
    self:consume(TOKENTYPES.LBR)
    while not self:match(TOKENTYPES.RBR) do
        local s = self:statement(EXPORT, Relative)
        table.insert(block, s)
    end
    VARIABLESPOP()
    NwSTACK = NwSTACK - 1
    return setmetatable(block, blockmeta)
end

function Parser:stateOrBlock(EXPORT, Relative)
    if self:get(0)[1] == TOKENTYPES.LBR then
        return self:block(EXPORT, Relative)
    end
    return "\n" .. GetStack(1) .. tostring(self:statement(EXPORT, Relative)) .. "\n"
end
function Parser:_IfElse()
    local condition = self:expression()
    local ifStatement = self:stateOrBlock()
    local elseStatement
    if self:match(TOKENTYPES.ELSE) then
        elseStatement = self:stateOrBlock()
        return "if " .. tostring(condition) .. " then " .. tostring(ifStatement) .. GetStack() .. "else " .. tostring(elseStatement) .. GetStack() .. "end"
    else
        return "if " .. tostring(condition) .. " then " .. tostring(ifStatement) .. GetStack() .. "end"
    end
end
function Parser:_WhileStatement()
    local condition = self:expression()
    local state = self:stateOrBlock()

    return "while " .. tostring(condition) .. " do " .. tostring(state) .. GetStack() .. "end"
end

function Parser:_ForStatement()

    self:consume(TOKENTYPES.LBRACKET)
    local init = self:AssignmentStatement(false)
    self:consume(TOKENTYPES.ENDBLOCK)
    local termination = self:expression()

    self:consume(TOKENTYPES.ENDBLOCK)
    local inc = self:expression()
    self:consume(TOKENTYPES.RBRACKET)

    local state = self:stateOrBlock()

    return "for " .. init .. ", " .. termination .. ", " .. inc .. " do" .. tostring(state) .. GetStack() .. "end"
end

function Parser:AssignmentStatement(force, EXPORT)
    local curr = self:get(0)

    if self:match(TOKENTYPES.WORD) then
        local r = self:get(0)[1]
        local var = curr[2]
        local init
        if force == nil then
            init = not VARIABLES[var]
        else
            init = force
        end

        if r == TOKENTYPES.POINT then
            self:consume(TOKENTYPES.POINT)
            local expr = self:consume(TOKENTYPES.WORD)[2]
            var = var .. "." .. expr
            EXPORT = true
            r = self:get(0)[1]
        end

        if r == TOKENTYPES.EQ then

            self:consume(TOKENTYPES.EQ)

            local expr, type = self:expression(var)

            return self:ParseAssignment(TOKENTYPES.EQ, var, expr, type, init, EXPORT), TOKENTYPES.EQ

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
        end

        return var
    elseif self:match(TOKENTYPES.ENDBLOCK) then
        return ";"
    elseif self:match(TOKENTYPES.LBRACKET) then
        print("A")
        local exp, type = self:expression()

        self:match(TOKENTYPES.RBRACKET)
        local exp2, type = self:expression()
        return "( " .. tostring(exp) .. " )" .. exp2
    elseif self:match(TOKENTYPES.KEYWORD) then
        local name = get(0)
        local type = curr.text
        if name.type == TOKENTYPES.WORD then
            consume(TOKENTYPES.WORD)
            consume(TOKENTYPES.EQ)
            return AssignmentStatement(name.text, type, self:expression(type))
        end
    end

    return throw("Unknown statement " .. self.pos .. ": " .. tostring(curr))
end
local function checkOnInit(init)
    if init then
        -- return throw("Variable " .. name .. " not initialized")
    end
end

local function checkOnNumber(type2)
    if type2 ~= TOKENTYPES.NUMBER then
        return throw("only numbers")
    end
end
local assmeta = {
    __tostring = function(self)
        return GetStack() .. self[1] .. self[2] .. self[3]
    end
}
function Parser:ParseAssignment(type, name, what, type2, init, export)

    if type == TOKENTYPES.EQ then
        return ((not export and init) and "local " or "") .. tostring(name) .. " = " .. tostring(what)
    end
    if type == TOKENTYPES.PLUSEQ then
        checkOnInit(init)
        -- checkOnNumber(type2)
        local name = tostring(name)
        return name .. " = " .. name .. " + " .. tostring(what)
    end
    if type == TOKENTYPES.STAREQ then
        checkOnInit(init)
        -- checkOnNumber(type2)
        local name = tostring(name)
        return name .. " = " .. name .. " * " .. tostring(what)
    end
    if type == TOKENTYPES.SLASHEQ then
        checkOnInit(init)
        -- checkOnNumber(type2)
        local name = tostring(name)
        return name .. " = " .. name .. " / " .. tostring(what)
    end
    if type == TOKENTYPES.PLUSPLUS then
        checkOnInit(init)
        -- checkOnNumber(VARIABLES[name])
        local name = tostring(name)
        return name .. " = " .. name .. " + 1"
    end
    if type == TOKENTYPES.MINUSMINUS then
        checkOnInit(init)
        -- checkOnNumber(VARIABLES[name])
        local name = tostring(name)
        return name .. " = " .. name .. " - 1"
    end
    if type == TOKENTYPES.MINUSEQ then
        checkOnInit(init)
        -- checkOnNumber(type2)
        local name = tostring(name)
        return name .. " = " .. name .. " - " .. tostring(what)
    end
    if type == TOKENTYPES.POINTER then
        checkOnInit(init)
        -- checkOnNumber(type2)
        local name = tostring(name)
        return name .. ":" .. what
    end
end

function Parser:expression(var)
    return self:_LogicalOr(var)
end

function Parser:_LogicalOr(var)
    local expr, type = self:_LogicalAnd(var)
    while true do
        ::CONTINUE::
        if self:match(TOKENTYPES.BARBAR) then
            expr = ConditionalExpression("||", expr, self:_LogicalAnd(var))
            goto CONTINUE
        end
        if self:match(TOKENTYPES.BAR) then
            expr = ConditionalExpression("|", expr, self:_LogicalAnd(var))
            goto CONTINUE
        end
        break
    end

    return expr, type
end

function Parser:_LogicalAnd(var)
    local expr, type = self:_Equality(var)
    while true do
        ::CONTINUE::
        if self:match(TOKENTYPES.AMPAMP) then
            expr = ConditionalExpression("&&", expr, self:_Equality(var))
            goto CONTINUE
        end
        if self:match(TOKENTYPES.AMP) then
            expr = ConditionalExpression("&", expr, self:_Equality(var))
            goto CONTINUE
        end
        break
    end
    return expr, type
end

function Parser:_Equality(var)
    local expr, type = self:_Conditional(var)
    if self:match(TOKENTYPES.EQEQ) then
        local expr2, type2 = self:_Conditional(var)
        expr = tostring(expr) .. " == " .. tostring(expr2)
    elseif self:match(TOKENTYPES.EXCLEQ) then
        local expr2, type2 = self:_Conditional(var)
        expr = tostring(expr) .. " ~= " .. tostring(expr2)
    end
    return expr, type
end

function Parser:_Conditional(var)
    local expr, type = self:_Additive(var)

    while true do
        ::CONTINUE::
        if self:match(TOKENTYPES.GT) then
            local expr2, type2 = self:_Additive(var)
            expr = tostring(expr) .. " > " .. tostring(expr2)
            goto CONTINUE
        elseif self:match(TOKENTYPES.GTEQ) then
            local expr2, type2 = self:_Additive(var)
            expr = tostring(expr) .. " >= " .. tostring(expr2)
            goto CONTINUE
        elseif self:match(TOKENTYPES.LT) then
            local expr2, type2 = self:_Additive(var)
            expr = tostring(expr) .. " < " .. tostring(expr2)
            goto CONTINUE
        elseif self:match(TOKENTYPES.LTEQ) then
            local expr2, type2 = self:_Additive(var)
            expr = tostring(expr) .. " <= " .. tostring(expr2)
            goto CONTINUE
        end
        break

    end
    return expr, type
end

function Parser:_Additive(var)
    local expr, type = self:_Multi(var)

    while true do
        ::CONTINUE::
        if self:match(TOKENTYPES.PLUS) then
            local expr2, type2 = self:_Multi(var)
            -- if not type then
            --     return throw("govno")
            -- end

            expr = tostring(expr) .. (" + ") .. tostring(expr2)
            -- if type == TOKENTYPES.STRING then
            --     expr = tostring(expr) .. (" .. ") .. tostring(expr2)
            -- else
            --     expr = tostring(expr) .. (" + ") .. tostring(expr2)
            -- end
            goto CONTINUE
        elseif self:match(TOKENTYPES.MINUS) then
            local expr2, type2 = self:_Multi(var)
            expr = tostring(expr) .. (" - ") .. tostring(expr2)
            goto CONTINUE
        end
        break

    end
    return expr, type
end

function Parser:_Multi(var)
    local expr, type = self:_Moduler(var)

    while true do
        ::CONTINUE::
        if self:match(TOKENTYPES.STAR) then
            local expr2, type2 = self:_Moduler(var)

            if type == TOKENTYPES.STRING and type2 == TOKENTYPES.NUMBER then
                expr = "( " .. tostring(expr) .. " )" .. (":rep( ") .. tostring(expr2) .. " )"
            else
                expr = tostring(expr) .. (" * ") .. tostring(expr2)
            end
            goto CONTINUE
        elseif self:match(TOKENTYPES.SLASH) then
            local expr2, type2 = self:_Moduler(var)

            if type == TOKENTYPES.STRING then
                expr = "( " .. tostring(expr) .. " )" .. (":split( ") .. tostring(expr2) .. " )"
            else
                expr = tostring(expr) .. (" / ") .. tostring(expr2)
            end
            goto CONTINUE
        end
        break

    end

    return expr, type
end

function Parser:_Moduler(var)
    local expr, type = self:_Sredne(var)

    while true do
        ::CONTINUE::
        if self:match(TOKENTYPES.FLEX) then
            local expr2, type2 = self:_Sredne(var)

            expr = tostring(expr) .. (" ^ ") .. tostring(expr2)

            goto CONTINUE
        elseif self:match(TOKENTYPES.MODULE) then
            local expr2, type2 = self:_Sredne(var)
            expr = tostring(expr) .. (" % ") .. tostring(expr2)
            goto CONTINUE
        elseif self:match(TOKENTYPES.COMMA) then
            local expr2, type2 = self:_Sredne(var)
            expr = tostring(expr) .. (", ") .. tostring(expr2)
        end
        break

    end

    return expr, type
end

function Parser:_Sredne(var)

    local expr, type = self:_Unary(var)
    if self:match(TOKENTYPES.MINUS) then
        local expr, type = self:_Unary(var)
        return "-" .. tostring(expr), type
    elseif self:match(TOKENTYPES.POINTER) then

        return tostring(expr) .. ":" .. self:expression()

    elseif self:match(TOKENTYPES.POINT) then
        return tostring(expr) .. "." .. self:expression(), TOKENTYPES.POINT

    end
    return expr, type
end

function Parser:_Unary(var)

    -- local expr, type = self:_Primary(var)
    if self:match(TOKENTYPES.MINUS) then
        local expr, type = self:_Primary(var)
        return "-" .. tostring(expr), type
    elseif self:match(TOKENTYPES.PLUS) then
        return self:_Primary(var)
    end
    return self:_Primary(var)
end
function Parser:getFString(left, center)
    local fstring = '"' .. tostring(left) .. '"..' .. center

    while self:get(0)[1] == TOKENTYPES.STRING do
        local left = self:consume(TOKENTYPES.STRING)[2]
        self:consume(TOKENTYPES.LBR)

        local center = self:statement(true)
        self:consume(TOKENTYPES.RBR)

        local ret = ""
        if self:match(TOKENTYPES.FSTRING) then
            fstring = fstring .. '..' .. self:getFString(left, center)
        else
            local right = self:consume(TOKENTYPES.STRING)[2]
            return fstring..'.."' .. tostring(left) .. '"..' .. center .. '.."' .. tostring(right) .. '"'
        end
    end
    return fstring
end
function Parser:_Primary(var)

    local curr = self:get(0)

    if self:match(TOKENTYPES.NUMBER) then
        if var then
            VARIABLES[var] = TOKENTYPES.NUMBER
        end
        return tostring(curr[2]), TOKENTYPES.NUMBER

    elseif self:get(0)[1] == TOKENTYPES.WORD and self:get(1)[1] == TOKENTYPES.LBRACKET then

        return self:_NewFunction(), TOKENTYPES.FUNCTION

    elseif self:match(TOKENTYPES.FSTRING) then

        -- local expr2,type2 = self:statement(true)
        -- while not self:get(0)[1] == TOKENTYPES.STRING do
        --     self:next()
        -- end

        local left = self:consume(TOKENTYPES.STRING)[2]
        self:consume(TOKENTYPES.LBR)
        local center = self:statement(true)
        self:consume(TOKENTYPES.RBR)
        local ret = ""
        if self:match(TOKENTYPES.FSTRING) then
            ret = self:getFString(left, center)
        else
            local right = self:consume(TOKENTYPES.STRING)[2]
            ret = '"' .. tostring(left) .. '"..' .. center .. '.."' .. tostring(right) .. '"'
        end
        -- print(self:get(0))
        return ret, TOKENTYPES.FSTRING

    elseif self:match(TOKENTYPES.CLASSNEW) then

        return self:expression()

    elseif self:match(TOKENTYPES.HEX_NUMBER) then

        -- return NumberExpression(tonumber("0x" .. curr.text), v)

    elseif self:match(TOKENTYPES.WORD) then

        if self:match(TOKENTYPES.LAMBDA) then
            return "function( " .. tostring(curr[2]) .. " )" .. self:stateOrBlock() .. GetStack() .. "end", TOKENTYPES.FUNCTION
        end

        if var then
            VARIABLES[var] = TOKENTYPES.WORD
        end
        return curr[2], VARIABLES[curr[2]]

    elseif self:match(TOKENTYPES.STRING) then
        if var then
            VARIABLES[var] = TOKENTYPES.STRING
        end
        return '"' .. tostring(curr[2]) .. '"', TOKENTYPES.STRING

    elseif self:match(TOKENTYPES.ENDBLOCK) then

        return "; ", TOKENTYPES.ENDBLOCK

    elseif self:match(TOKENTYPES.LBRACKET) then
        local r = ""

        if self:get(0)[1] ~= TOKENTYPES.RBRACKET then

            r, type = self:expression(v)

        end
        self:match(TOKENTYPES.RBRACKET)

        if self:match(TOKENTYPES.LAMBDA) then
            return "function( " .. tostring(r) .. " )" .. tostring(self:stateOrBlock()) .. GetStack() .. "end", TOKENTYPES.FUNCTION
        end
        return "( " .. r .. " )", type
    end

    return throw("Unknown expression " .. self.pos .. ": " .. tostring(curr))
end

function Parser:_NewFunction(EXPORT)

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
        return (not EXPORT and "local " or "") .. tostring(name) .. " = function " .. "( " .. table.concat(args, ", ") .. " )\n" .. tostring(body) .. GetStack() .. "end", TOKENTYPES.EQ
    end
    return tostring(name) .. "( " .. table.concat(args, ", ") .. " )"
end

VARIABLES = {}
local STACK_VARIABLES = {}

function VARIABLESPUSH()
    table.insert(STACK_VARIABLES, table.copy(VARIABLES))
end
function VARIABLESPOP()
    VARIABLES = table.remove(STACK_VARIABLES)
end

