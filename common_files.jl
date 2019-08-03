#This information would be in an operator table
function isOperator(c::Char)
    return !isdigit(c) && !isletter(c)
end

#This would be determined by an operator table
function getPriority(c::Char)
    if c == '+' || c == '-'
        return 1
    elseif c == '*' || c == '/'
        return 2
    elseif c == '^'
        return 3
    end

    return 0
end
