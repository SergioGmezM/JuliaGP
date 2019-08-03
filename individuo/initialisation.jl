include("nodes.jl") # For Node structs.

# Generator represents the way that a population is going to be generated.
# pop_size: size of the population, number of individuals.
# max_d: maximun depth of the individuals in the population.
# method: method used for generating the individuals.
struct Generator
    pop_size::Int
    max_d::Int
    method::String

    function Generator(pop_size, max_d, method)
        if pop_size > 0 && max_d >= 0 && (method == "full" || method == "grow")
            new(pop_size, max_d, method)
        else
            error("Could not build Generator instance")
        end
    end
end # struct Generator

# Gets the population size.
getPopSize(gen::Generator) = gen.pop_size

# Gets the maximun depth of the individuals
getMaxDepth(gen::Generator) = gen.max_d

# Gets the method used for individuals initialisation.
getMethod(gen::Generator) = gen.method

# Generates a tree of depth max_d using either full or grow methods given
# the function set and the terminal set.
function gen_rnd_expr(gen::Generator, functionSet::Array{FunctionNode}, terminalSet::Array{TerminalNode}, max_d::Int)

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
end

# Generates a population calling gen_rnd_expr multiple times.
function gen_population(gen::Generator, functionSet::Array{FunctionNode}, terminalSet::Array{TerminalNode})

    population = Array{Array{Node}}(undef, 0)
    pop_size = getPopSize(gen)

    for i = 1:pop_size
        push!(population, gen_rnd_expr(gen, functionSet, terminalSet, getMaxDepth(gen)))
    end

    return population
end
