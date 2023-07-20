--@name Parser/Token
--@author discord.gg/6Q5NnHQTrh // kekobka // STEAM_0:0:186583728
--@shared


local Token = class("Token")

Token.types = {
    NUMBER = "NUMBER", -- 1
    PLUS = "PLUS", -- +
    PLUSEQ = "PLUSEQ", -- +=
    PLUSPLUS = "PLPL", -- ++

    MINUS = "MINUS", -- -
    MINUSEQ = "MINUSEQ", -- -=
    MINUSMINUS = "MINMIN", -- --

    SLASH = "SLASH", -- /
    SLASHEQ = "SLASHEQ", -- /=

    STAR = "STAR", -- *
    STAREQ = "STAREQ", -- *=

    FLEX = "FLEX", -- ^
    FLEXEQ = "FLEXEQ", -- ^=
    MODULE = "MODULE", -- %
    LBRACKET = "LB", -- (
    RBRACKET = "RB", -- )
    HEX_NUMBER = "HEXN", -- #123123
    
    WORD = "WORD", -- anyword
    TEXT = "TEXT", -- anytext
    
    EQ = "EQ", -- =
    EQEQ = "EQEQ", -- ==
    EXCL = "EXCL", -- !
    EXCLEQ = "EXCLEQ", -- !=
    
    LT = "LT", -- <
    LTEQ = "LTEQ", -- <=
    
    GT = "GT", -- >
    GTEQ = "GTEQ", -- >=
    
    IF = "IF", -- if
    ELSE = "ELSE", -- else
    WHILE = "WHILE", -- while
    FOR = "FOR", -- for
    BREAK = "BREAK", -- break
    CONTINUE = "CONTINUE", -- continue
    DEF = "DEF", -- def
    
    COMMA = "COMMA", -- ,
    
    BAR = "BAR", -- |
    BARBAR = "BARBAR", -- ||
    
    AMP = "AMP", -- &
    AMPAMP = "AMPAMP", -- &&
    
    LBR = "LBR",
    RBR = "RBR",
    KEYWORD = "KEYWORD",
    
    EOF = "EOF",
}
function Token.__tostring(self)
    return self.type.." "..self.text
end

function Token:initialize(type, text)
    self.type = type or ""
    self.text = text or ""
end



return Token
