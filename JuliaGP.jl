include("initialisation.jl") # For Generator struct.
include("evaluator.jl") # For Fitness and Evaluator structs.
include("selector.jl") # For selection method for crossover.
include("sets.jl") # For setFunctionSet and setTerminalSet.
include("nodes.jl") # For Node structs.


# JuliaGP represents a whole system of GP for Julia. The user will need to
# specify the tools that the system will be using in order to find the best
# individual of a population that satisfies a fitness function, also given by
# the user. These tools include:
#   _generator: the population generator.
#   _evaluator: the evaluator of the individuals' fitnesses.
#   _selector: the way that the population is going to be selected for crossover.
#   _crossover: the crossover operation between individuals of a population.
#   _mutation: the mutation operation for the individuals of a population.
#   _replacer: the way the offspring is going to replace the original population.
#   _functionSet: the set of operations defined by the user.
#   _terminalSet: the set of terminals defined by the user.
struct JuliaGP
    _generator::Generator
    _evaluator::Evaluator
    _selector::SelectionOperator
    _functionSet::Array{FunctionNode}
    _terminalSet::Array{TerminalNode}
end # struct JuliaGP

# Constructors for the JuliaGP struct (most likely used).

function JuliaGP(generator::Generator, evaluator::Evaluator)
    JuliaGP(generator, evaluator, TournamentSelector(2), Array{FunctionNode}(undef, 0), Array{TerminalNode}(undef, 0))
end

function JuliaGP(generator::Generator, evaluator::Evaluator, selector::SelectionOperator)
    JuliaGP(generator, evaluator, selector, Array{FunctionNode}(undef, 0), Array{TerminalNode}(undef, 0))
end

# -------------------------------------------------------------------------------------------------------

# Setter of the function set of the system.
function readFunctions(gp::JuliaGP, filename::AbstractString)
    functions = setFunctionSet(filename)
    copy!(gp._functionSet, functions)
end

# Setter of the terminal set of the system.
function readTerminals(gp::JuliaGP, filename::AbstractString)
    terminals = setTerminalSet(filename)
    copy!(gp._terminalSet, terminals)
end

# Population generation.
gen_pop(gp::JuliaGP) = gen_population(gp._generator, gp._functionSet, gp._terminalSet)

# Selects parents for crossover.
select_parents(gp::JuliaGP, pop::Array{Array{Node}}) = select(gp._selector, pop, gp._evaluator)

# Individual evaluation.
# This function transforms an array of Nodes to a string maintaining the prefix
# notation of the original array and adding parentheses in order to express
# priority. The goal is to transform the array into a string that Julia recognises
# so that it can be evaluated later by Julia's eval function.
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
evaluate(gp::JuliaGP, individual::Array{Node}) = evaluate(gp._evaluator, individual)
