
function string.isLetter(s)
    return #string.gsub(s, "[^A-Za-z_]+", "") > 0
end

function string.isLetterOrDigit(s)
    return (#string.gsub(s, "[^A-Za-z_]+", "") > 0) or tonumber(s)
end
