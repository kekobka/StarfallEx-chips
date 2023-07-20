--@name Parser/Lexer
--@author discord.gg/6Q5NnHQTrh // kekobka // STEAM_0:0:186583728
--@shared
--@include libs/task.txt
local Task = require("libs/task.txt")
--@include ./token.lua
local Token = require("./token.lua")
local TOKENTYPES = Token.types

local Lexer = class("Lexer")
KEYWORDS = {
    ["string"] = TOKENTYPES.TEXT,
    ["number"] = TOKENTYPES.NUMBER,
    ["any"] = true,

}
local OPERATOR_CHARS = {
    ["+"] = TOKENTYPES.PLUS,
    ["-"] = TOKENTYPES.MINUS,
    ["*"] = TOKENTYPES.STAR,
    ["/"] = TOKENTYPES.SLASH,
    ["^"] = TOKENTYPES.FLEX,
    ["%"] = TOKENTYPES.MODULE,

    ["("] = TOKENTYPES.LBRACKET,
    [")"] = TOKENTYPES.RBRACKET,
    ["{"] = TOKENTYPES.LBR,
    ["}"] = TOKENTYPES.RBR,
    [","] = TOKENTYPES.COMMA,

    ["="] = TOKENTYPES.EQ,
    ["!"] = TOKENTYPES.EXCL,
    ["<"] = TOKENTYPES.LT,
    [">"] = TOKENTYPES.GT,
    ["&"] = TOKENTYPES.AMP,
    ["|"] = TOKENTYPES.BAR,

    ["=="] = TOKENTYPES.EQEQ,
    ["<="] = TOKENTYPES.LTEQ,
    [">="] = TOKENTYPES.GTEQ,
    ["!="] = TOKENTYPES.EXCLEQ,
    ["&&"] = TOKENTYPES.AMPAMP,
    ["||"] = TOKENTYPES.BARBAR,

    ["+="] = TOKENTYPES.PLUSEQ,
    ["++"] = TOKENTYPES.PLUSPLUS,
    ["--"] = TOKENTYPES.MINUSMINUS,
    ["-="] = TOKENTYPES.MINUSEQ,
    ["/="] = TOKENTYPES.SLASHEQ,
    ["*="] = TOKENTYPES.STAREQ,
    ["^="] = TOKENTYPES.FLEXEQ,
    
}

local hexsymbols = "abcdef"
function string.isLetter(s)
    return #string.gsub(s, "[^A-Za-z]+", "") > 0
end
function string.isLetterOrDigit(s)
    return ((#string.gsub(s, "[^A-Za-z]+", "") > 0) or tonumber(s))
end
function Lexer:initialize(input)
    local input = input
    local tokens = {}
    local length = input:len()
    local pos = 0

    local function peek(relativePosition)
        local position = pos + relativePosition
        if position > length then
            return nil
        end
        return input[position]
    end

    local function addToken(type, text)
        table.insert(tokens, Token:new(type, text))
    end

    local function next()
        pos = pos + 1
        return peek(0)
    end

    local function tokenizeNumber()
        local buff = ""
        local point
        local curr = peek(0)
        while true do
            if curr == "." then
                if point then
                    return throw("Invalid number")
                end
                point = true
            elseif not tonumber(curr) then
                break
            end
            buff = buff .. curr
            curr = next()
            -- //Task.yield()
        end
        addToken(TOKENTYPES.NUMBER, buff)
    end

    local function tokenizeHexNumber()

        local buff = ""
        local curr = next()
        while tonumber(curr) or hexsymbols:find(curr:lower()) do
            buff = buff .. curr
            curr = next()
            -- //Task.yield()
        end

        addToken(TOKENTYPES.HEX_NUMBER, buff)
    end

    local function tokenizeWord()

        local buff = ""
        local curr = peek(0)
        while true do
            if not string.isLetterOrDigit(curr) and curr ~= "_" and curr ~= "$" then
                break
            end
            buff = buff .. curr
            curr = next()
            -- //Task.yield()
        end
        if KEYWORDS[buff] then
            return addToken(TOKENTYPES.KEYWORD, buff)
        end
        if buff == "if" then
            return addToken(TOKENTYPES.IF)
        elseif buff == "else" then
            return addToken(TOKENTYPES.ELSE)
        elseif buff == "for" then
            return addToken(TOKENTYPES.FOR)
        elseif buff == "while" then
            return addToken(TOKENTYPES.WHILE)
        elseif buff == "fn" then
            return addToken(TOKENTYPES.DEF)
        elseif buff == "break" then
            return addToken(TOKENTYPES.BREAK)
        elseif buff == "continue" then
            return addToken(TOKENTYPES.CONTINUE)
        end

        addToken(TOKENTYPES.WORD, buff)
    end

    local function tokenizeText()

        local buff = ""
        local curr = next()
        while true do

            if curr == '\\' then
                curr = next()
                if curr == '"' then
                    buff = buff .. curr
                    curr = next()
                    goto CONTINUE
                elseif curr == 'n' then
                    buff = buff .. "\n"
                    curr = next()
                    goto CONTINUE
                elseif curr == 't' then
                    buff = buff .. '\t'
                    curr = next()
                    goto CONTINUE
                end
                buff = buff .. '\\'
                goto CONTINUE
            end

            if curr == '"' then
                break
            end
            buff = buff .. curr
            curr = next()
            ::CONTINUE::
            -- //Task.yield()
        end

        addToken(TOKENTYPES.TEXT, buff)
        next()
    end

    local function tokenizeComment()
        local curr = peek(0)
        while not ("\r\n\0"):find(curr) do
            curr = next()
        end
    end

    local function tokenizeMultilineComment()
        local curr = peek(0)
        while true do
            if curr == "\0" then
                return throw("Missing close multiline comment tag")
            end
            if curr == "*" and peek(1) == "/" then
                break
            end
            curr = next()
        end
        next()
        next()
    end

    local function tokenizeOperator()
        local curr = peek(0)
        if curr == "/" then
            if peek(1) == "/" then
                next()
                next()
                tokenizeComment()
                return
            elseif peek(1) == "*" then
                next()
                next()
                tokenizeMultilineComment()
                return
            end
        end
        local buff = ""
        while true do
            if not OPERATOR_CHARS[buff .. curr] and buff ~= "" then
                addToken(OPERATOR_CHARS[buff])
                return
            end
            buff = buff .. curr
            curr = next()
        end

    end

    function self:tokenize()
        -- //return Task.run(function()
        while pos <= length do
            local curr = peek(0)
            if tonumber(curr) then
                tokenizeNumber()
            elseif curr == "#" then
                tokenizeHexNumber()

            elseif curr == '"' then
                tokenizeText()

            elseif OPERATOR_CHARS[curr] then
                tokenizeOperator()

            elseif string.isLetter(curr) then
                tokenizeWord()

            else
                next()

            end
            -- //Task.yield()
        end
        return tokens
        -- //end)
    end

end

return Lexer

