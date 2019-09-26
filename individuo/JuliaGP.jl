include("initialisation.jl") # For Generator struct.
include("evaluator.jl") # For Fitness and Evaluator structs.
include("sets.jl") # For setFunctionSet and setTerminalSet.
include("nodes.jl") # For Node structs.


# JuliaGP represents a whole system of GP for Julia. The user will need to
# specify the tools that the system will be using in order to find the best
# individual of a population that satisfies a fitness function, also given by
# the user. These tools include:
#   generator: the population generator.
#   evaluator: the evaluator of the individuals' fitnesses.
#   crossover: the crossover operation between individuals of a population.
#   mutation: the mutation operation for the individuals of a population.
#   selector: the way the offspring is going to replace the original population.
#   functionSet: the set of operations defined by the user.
#   terminalSet: the set of terminals defined by the user.
struct JuliaGP
    generator::Generator
    evaluator::Evaluator
    functionSet::Array{FunctionNode}
    terminalSet::Array{TerminalNode}
end # struct JuliaGP

# Constructor for the JuliaGP struct (most likely used).
JuliaGP(generator::Generator, evaluator::Evaluator) = JuliaGP(generator, evaluator, Array{FunctionNode}(undef, 0), Array{TerminalNode}(undef, 0))

# Setter of the function set of the system.
function readFunctions(gp::JuliaGP, filename::AbstractString)
    functions = setFunctionSet(filename)
    copy!(gp.functionSet, functions)
end

# Setter of the terminal set of the system.
function readTerminals(gp::JuliaGP, filename::AbstractString)
    terminals = setTerminalSet(filename)
    copy!(gp.terminalSet, terminals)
end

# Population generation.
gen_pop(gp::JuliaGP) = gen_population(gp.generator, gp.functionSet, gp.terminalSet)

# Individual evaluation.
# The conversion from prefix notation to infix notation will be done using
# an array of String objects, in order to express priority between operators.
#
# First, the individual is read backwards (postfix notation). When a terminal
# node is encountered, it is added to a stack straight away. When a function
# node is encountered, as many operand as its arity indicates are popped from
# the stack and put in an auxiliar string that forms the expression:
# "(<function name>(<operand1>, <operand2>, ...))" and then, it is pushed to
# the stack. Once the whole individual has been evaluated, its infix notation
# will be at the top of the stack. Then, the fitness function is called.
#
# The process to form a string expression for '2 + x' (supposing x equals to 3.2)
# first begins by transforming every function to its 'call form', so
# '2 + x' would be: '+(2, x)'. Each operator put in the final string will begin
# called using its Symbol, so, user-defined operators that behave differently
# from Julia's should be defined in a separate file. When a VariableNode or a
# NoArgsFunctionNode is encountered, what is put in the final string is its
# value. So the final string would contain "+(2, 3.2)".
function evaluate(gp::JuliaGP, individual::Array{Node})

    stack = Array{String}(undef, 0)

    for node in Iterators.reverse(individual)

        if typeof(node) <: FunctionNode

            operators = Array{String}(undef, 0)

            for i = 1:getArity(node)
                push!(operators, pop!(stack))
            end

            temp = "( " * getSymbol(node) * "("
            for i = 1:(getArity(node) - 1)
                temp *= operators[i] * ", "
            end
            temp *= operators[getArity(node)] * " ))"

            push!(stack, temp)

        elseif typeof(node) <: TerminalNode
            push!(stack, string(eval(node)))

        end
    end

    infixInd = pop!(stack)

    gp.evaluator.fitnessFunction(gp.evaluator.fitness, infixInd)
end
