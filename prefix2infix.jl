include("common_files.jl")

function prefix2infix(prefix::String)
    stack = Array{String}(undef, 0)
    priority = 3
    lastOneOperator = false

    for c in Iterators.reverse(prefix)

        #If a terminal is found, pushes it to the stack
        if !isOperator(c)
            push!(stack, "" * c)
            lastOneOperator = false

        #If an operator is found, binds the last
        #two elements of the stack using this operator
        #and sets the priority level, which determines
        #if parentheses are needed
        elseif !isempty(stack)
            aux = Array{String}(undef, 0)

            if priority < getPriority(c) && length(stack[end]) > 1
                push!(aux, "(" * pop!(stack) * ")")
            else
                push!(aux, pop!(stack))
            end

            push!(aux, "" * c)

            if (priority < getPriority(c) && length(stack[end]) > 1) || (lastOneOperator && length(stack[end]) > 1)
                push!(aux, "(" * pop!(stack) * ")")
            else
                push!(aux, pop!(stack))
            end

            priority = getPriority(c)
            push!(stack, string(aux...))
            lastOneOperator = true
        end
    end

    return pop!(stack)
end

println(prefix2infix("*+a-bc/-de-f+gh"))
