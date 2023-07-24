Tokenizer = class("Tokenizer")

local OPERATOR_CHARS = OPERATOR_CHARS
local TOKENTYPES = TOKENTYPES
local TOKENTYPESSTRING = TOKENTYPESSTRING

function Tokenizer:initialize(code)
    self.code = code
    self.pos = 0
    self.length = code:len()
    self.TOKENS = {}
    self:tokenize()
end
function Tokenizer:__tostring()
    local ret = ""
    for _, token in next, self.TOKENS do
        ret = ret .. tostring(token) .. "\n"
    end
    return ret
end
function Tokenizer:tokenize()
    while self.pos <= self.length do
        local curr = self:peek(0)
        if tonumber(curr) then
            self:tokenizeNumber()
        elseif curr == "." then
            self:addToken(TOKENTYPES.POINT)
            self:next()
        elseif curr == ";" then
            self:addToken(TOKENTYPES.ENDBLOCK)
            self:next()
        elseif curr == '"' or curr == "'" then
            self:tokenizeString()
        elseif OPERATOR_CHARS[curr] then
            self:tokenizeOperator()
        elseif string.isLetter(curr) then
            self:tokenizeWord()
        else
            self:next()
        end

    end
end

function Tokenizer:peek(relpos)
    local position = self.pos + relpos
    if position > self.length then
        return nil
    end
    return self.code[position]
end

function Tokenizer:next()
    self.pos = self.pos + 1
    return self:peek(0)
end

local TokenMeta = {
    __tostring = function(self)
        return ParseToken(self[1]) .. " " .. tostring(self[2] or "")
    end
}

function Tokenizer:addToken(type, text)
    table.insert(self.TOKENS, setmetatable({type, text}, TokenMeta))
end

function Tokenizer:tokenizeNumber()
    local buff = ""
    local point
    local curr = self:peek(0)

    while curr do
        if curr == "." then
            if point then
                return throw("Invalid number")
            end
            point = true
        elseif not tonumber(curr) then
            break
        end
        buff = buff .. curr
        curr = self:next()
    end

    self:addToken(TOKENTYPES.NUMBER, buff)
end

function Tokenizer:tokenizeComment()
    local curr = self:peek(0)
    while curr and not ("\r\n"):find(curr) do
        curr = self:next()
    end
end

function Tokenizer:tokenizeMultilineComment()
    local curr = self:peek(0)
    while curr do
        if curr == "*" and self:peek(1) == "/" then
            break
        end
        curr = self:next()
    end
    self:next()
    self:next()
end
function Tokenizer:tokenizeWord()

    local buff = ""
    local curr = self:peek(0)
    while true do
        if not string.isLetterOrDigit(curr) and curr ~= "_" then
            break
        end
        buff = buff .. curr
        curr = self:next()
    end
    -- if KEYWORDS[buff] then
    --     return addToken(TOKENTYPES.KEYWORD, buff)
    -- end
    if buff == "if" then
        return self:addToken(TOKENTYPES.IF)
    elseif buff == "else" then
        return self:addToken(TOKENTYPES.ELSE)
    elseif buff == "for" then
        return self:addToken(TOKENTYPES.FOR)
    elseif buff == "while" then
        return self:addToken(TOKENTYPES.WHILE)
    elseif buff == "method" then
        return self:addToken(TOKENTYPES.FUNCTION)
    elseif buff == "return" then
        return self:addToken(TOKENTYPES.RETURN)
    elseif buff == "export" then
        return self:addToken(TOKENTYPES.EXPORT)
    elseif buff == "break" then
        return self:addToken(TOKENTYPES.BREAK)
    elseif buff == "class" then
        return self:addToken(TOKENTYPES.CLASSDEF)
    elseif buff == "constructor" then
        return self:addToken(TOKENTYPES.CLASSCONSTRUCTOR)
    elseif buff == "new" then
        return self:addToken(TOKENTYPES.CLASSNEW)
    elseif buff == "continue" then
        return self:addToken(TOKENTYPES.CONTINUE)
    end
    
    self:addToken(TOKENTYPES.WORD, buff)
end

function Tokenizer:tokenizeString()

    local buff = ""
    local curr = self:next()
    while curr do

        if curr == '\\' then
            curr = self:next()
            if curr == '"' then
                buff = buff .. curr
                curr = self:next()
                goto CONTINUE
            elseif curr == 'n' then
                buff = buff .. "\n"
                curr = self:next()
                goto CONTINUE
            elseif curr == 't' then
                buff = buff .. '\t'
                curr = self:next()
                goto CONTINUE
            end
            buff = buff .. '\\'
            goto CONTINUE
        end

        if curr == '"' or curr == "'" then
            break
        end
        buff = buff .. curr
        curr = self:next()
        ::CONTINUE::
    end

    self:addToken(TOKENTYPES.STRING, buff)
    self:next()
end

function Tokenizer:tokenizeOperator()
    local curr = self:peek(0)
    if curr == "/" then
        if self:peek(1) == "/" then
            self:next()
            self:next()
            self:tokenizeComment()
            return
        elseif self:peek(1) == "*" then
            self:next()
            self:next()
            self:tokenizeMultilineComment()
            return
        end
    end
    local buff = ""
    while curr do
        if not OPERATOR_CHARS[buff .. curr] and buff ~= "" then
            return self:addToken(OPERATOR_CHARS[buff])
        end
        buff = buff .. curr
        curr = self:next()
    end
end