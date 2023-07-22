--@include ./TOKENTYPES.lua
require("./TOKENTYPES.lua")

OPERATOR_CHARS = {
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

    ["=>"] = TOKENTYPES.LAMBDA,

    [";"] = TOKENTYPES.ENDBLOCK

}
