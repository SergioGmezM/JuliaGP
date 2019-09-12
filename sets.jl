include("nodes.jl") # For Node structs.

# Converts the given value to the given type, throws an error if conversion
# is impossible.
function convertType(type::AbstractString, value::AbstractString)
    try
        convert(eval(Symbol(type)), value)
    catch
        try
            parse(eval(Symbol(type)), value)
        catch
            error("Could not convert $value to type $type")
        end
    end
end

# Sets a function set with the functions specified in the given file.
function setFunctionSet(filename::AbstractString)
    if !isfile(filename)
        error("Could not open $filename, file doesn't exist in working directory")
    end

    file = open(filename)
    functionSet = Array{FunctionNode}(undef, 0)

    for line in eachline(file)
        fields = split(line)

        symbol = String(fields[1])
        func = String(fields[2])
        arity = parse(Int, fields[3])
        fields[4] == "true" ? conmutative = true : conmutative = false

        if length(fields) > 4
            sentence = String(fields[5])
            returnType = String(fields[6])
            argTypes = fields[7:(6+arity)]
            push!(functionSet, FunctionNode(symbol, Symbol(func), arity, conmutative, sentence, returnType, argTypes))
        else
            push!(functionSet, FunctionNode(symbol, Symbol(func), arity, conmutative))
        end
    end

    close(file)

    return functionSet
end

# Sets a terminal set with the terminals specified in the given file.
function setTerminalSet(filename::AbstractString)
    if !isfile(filename)
        error("Could not open $filename, file doesn't exist in working directory")
    end

    file = open(filename)
    terminalSet = Array{TerminalNode}(undef, 0)

    for line in eachline(file)
        fields = split(line)

        if fields[1] == "var" # VariableNode
            symbol = String(fields[2])
            type = String(fields[3])
            value = convertType(type, fields[4])
            push!(terminalSet, VariableNode(symbol, value))

        elseif fields[1] == "const" # ConstantNode
            type = fields[2]
            value = convertType(type, fields[3])
            push!(terminalSet, ConstantNode(value))

        elseif fields[1] == "func" # NoArgsFunctionNode
            symbol = String(fields[2])
            func = String(fields[3])

            if length(fields) > 3
                returnType = String(fields[4])
                push!(terminalSet, NoArgsFunctionNode(symbol, Symbol(func), returnType))
            else
                push!(terminalSet, NoArgsFunctionNode(symbol, Symbol(func)))
            end
        else
            @warn "Type of terminal node not supported: $(fields[1])"
        end
    end

    close(file)

    return terminalSet
end
