include("nodes.jl") # For Node structs.

# Generator represents the way that a population is going to be generated.
#   pop_size: size of the population, number of individuals.
#   max_d: maximun depth of the individuals in the population.
#   method: method used for generating the individuals.
#   RHH_factor: when using Ramped Half-Half initialisation, this is the
#   pertentage of trees generated using full method, 1-RHH_factor will be the
#   percentage of trees generated using grow method.
struct Generator
    pop_size::Int
    max_d::Int
    method::String
    RHH_factor::Float64

    function Generator(pop_size, max_d, method, RHH_factor)
        if pop_size > 0 && max_d >= 0 && (method == "full" || method == "grow" || method == "RHH") && 0 <= RHH_factor <= 1
            new(pop_size, max_d, method, RHH_factor)
        else
            error("Could not build Generator instance")
        end
    end
end # struct Generator

# Second constructor for Generator struct.
Generator(pop_size, max_d, method) = Generator(pop_size, max_d, method, 0.5)

# Gets the population size.
getPopSize(gen::Generator) = gen.pop_size

# Gets the maximun depth of the individuals
getMaxDepth(gen::Generator) = gen.max_d

# Gets the method used for individuals initialisation.
getMethod(gen::Generator) = gen.method

# Gets the percentage of trees generated usign full method.
getFactor(gen::Generator) = gen.RHH_factor

# Generates a tree of depth max_d using either full or grow methods given
# the function set and the terminal set.
"""function gen_rnd_expr(gen::Generator, functionSet::Array{FunctionNode}, terminalSet::Array{TerminalNode}, max_d::Int)

    expr = Array{Node}(undef, 0)
    prob = length(terminalSet)/(length(terminalSet) + length(functionSet))
    method = getMethod(gen)

    if max_d == 0 || (method == "grow" && rand() < prob)
        push!(expr, rand(terminalSet))
    else
        func = Array{Node}(undef, 0)
        args = Array{Node}(undef, 0)
        push!(func, rand(functionSet))

        for i = 1:getArity(func[1])
            append!(args, gen_rnd_expr(gen, functionSet, terminalSet, max_d-1))
        end

        append!(expr, append!(func, args))
    end

    return expr
end"""

# Generates a tree of depth max_d using grow method given
# the function set and the terminal set.
function rnd_grow_expr(gen::Generator, functionSet::Array{FunctionNode}, terminalSet::Array{TerminalNode}, max_d::Int)

    expr = Array{Node}(undef, 0)
    prob = length(terminalSet)/(length(terminalSet) + length(functionSet))

    if max_d == 0 || rand() < prob
        push!(expr, rand(terminalSet))
    else
        push!(expr, rand(functionSet))

        for i = 1:getArity(expr[1])
            append!(expr, rnd_grow_expr(gen, functionSet, terminalSet, max_d-1))
        end
    end

    return expr
end

# Generates a tree of depth max_d using full method given
# the function set and the terminal set.
function rnd_full_expr(gen::Generator, functionSet::Array{FunctionNode}, terminalSet::Array{TerminalNode}, max_d::Int)

    expr = Array{Node}(undef, 0)

    if max_d == 0
        push!(expr, rand(terminalSet))
    else
        push!(expr, rand(functionSet))

        for i = 1:getArity(expr[1])
            append!(expr, rnd_full_expr(gen, functionSet, terminalSet, max_d-1))
        end
    end

    return expr
end

# Generates a population calling the specified function.
function gen_population(gen::Generator, functionSet::Array{FunctionNode}, terminalSet::Array{TerminalNode})

    population = Array{Array{Node}}(undef, 0)
    pop_size = getPopSize(gen)

    if getMethod(gen) == "grow"
        genFunction = rnd_grow_expr
        N = pop_size
    elseif getMethod(gen) == "full"
        genFunction = rnd_full_expr
        N = pop_size
    elseif getMethod(gen) == "RHH"
        genFunction = rnd_grow_expr
        N = pop_size - pop_size*getFactor(gen)

        for i = 1:(pop_size-N)
            push!(population, rnd_full_expr(gen, functionSet, terminalSet, getMaxDepth(gen)))
        end
    end

    for i = 1:N
        push!(population, genFunction(gen, functionSet, terminalSet, getMaxDepth(gen)))
    end

    return population
end
