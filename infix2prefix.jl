include("common_files.jl")

function infix2postfix(infix::String)

    #Surround infix with ( )
    infix = "(" * infix * ")"
    stack = Array{Char}(undef, 0)
    output = Array{Char}(undef, 0)

    for c in infix

        #If the scanned character is an
        #operand, add it to output.
        if isdigit(c) || isletter(c)
            push!(output, c)

        #If the scanned character is an
        #‘(‘, push it to the stack.
        elseif c == '('
            push!(stack, c)

        #If the scanned character is an
        #‘)’, pop and output from the stack
        #until an ‘(‘ is encountered.
        elseif c == ')'
            while !isempty(stack) && last(stack) != '('
                push!(output, pop!(stack))
            end

            #Remove '(' from the stack
            if !isempty(stack)
                pop!(stack)
            end

        #Operator found
        else
            if isOperator(last(stack))
                while !isempty(stack) && getPriority(c) <= getPriority(last(stack))
                    push!(output, pop!(stack))
                end

                #Push current Operator on stack
                push!(stack, c)
            end
        end
    end

    postfix = string(output...)

    return postfix
end


function infix2prefix(infix::String)

    """
    1) Reverse String
    2) Replace ( with ) and vice versa
    3) Get Postfix
    4) Reverse Postfix
    """

    #Reverse infix
    r_infix = reverse(infix)
    aux_r_infix = Array{Char}(undef, 0)

    #Replace ( with ) and vice versa
    for c in r_infix

        if c == '('
            push!(aux_r_infix, ')')

        elseif c == ')'
            push!(aux_r_infix, '(')

        else
            push!(aux_r_infix, c)
        end
    end

    postfix = infix2postfix(string(aux_r_infix...))

    #Reverse postfix
    prefix = reverse(postfix)

    return prefix
end

println(infix2prefix("(a+b-c)*(d-e)/(f-g+h)"))
