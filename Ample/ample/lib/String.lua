
function string.isLetter(s)
    return #string.gsub(s, "[^A-Za-z]+", "") > 0
end

function string.isLetterOrDigit(s)
    return (#string.gsub(s, "[^A-Za-z]+", "") > 0) or tonumber(s)
end
