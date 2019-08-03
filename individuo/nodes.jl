# Node is the abstract type that will contain every node of the expression tree.
abstract type Node end

# FunctionNode represents a non-terminal node of the expression tree.
#   symbol: the character sequence that identifies the function node.
#   func: the actual function that will be executed for that function node.
#   arity: the number of parameters for the function, also, the number of
#   children of the function node.
#   sentence: determines wether the function is a statement or an expression.
#   returnType: type of the returning value of a function.
#   argTypes: types of the arguments of the function.
struct FunctionNode <: Node
    symbol::AbstractString
    func::Symbol
    arity::Int8
    conmutative::Bool
    sentence::AbstractString
    returnType::AbstractString
    argTypes::Array{AbstractString}

    function FunctionNode(symbol, func, arity, conmutative, sentence, returnType, argTypes)

        if arity <= 0
            error("Could not create FunctionNode instance: $symbol")
        end

        new(symbol, func, arity, conmutative, sentence, returnType, argTypes)
    end
end # struct FunctionNode

# Second constructor of FunctionNode struct.
FunctionNode(symbol, func, arity, conmutative) = FunctionNode(symbol, func, arity, conmutative, "", "", Array{AbstractString}(undef, 0))

# Gets the arity of a given function node.
getArity(node::FunctionNode) = node.arity

# Checks if the operation is conmutative.
isConmutative(node::FunctionNode) = node.conmutative

# Gets the return type of a function node
getReturnType(node::FunctionNode) = node.returnType

# Executes the function of the function node.
eval(node::FunctionNode, arg, args...) = eval(node.func)(arg, args...)


# TerminalNode is an abstract type and represents a terminal node of the expression tree.
abstract type TerminalNode <: Node end

# VariableNode represents an identifier with a value assigned by the user.
#   symbol: identifier of the variable.
#   value: value of the variable.
struct VariableNode <: TerminalNode
    symbol::AbstractString
    value
end # struct VariableNode

# ConstantNode represents a single value.
#   value: value of the constant.
struct ConstantNode <: TerminalNode
    value
end # struct ConstantNode

# NoArgsFunctionNode represents a function node that has 0 arity (no arguments)
# and it's considered as a terminal node in the expression tree.
#   symbol: identifier of the function.
#   func: the actual function that will be executed for that terminal node.
#   returnType: type of the returning value of the function.
struct NoArgsFunctionNode <: TerminalNode
    symbol::AbstractString
    func::Symbol
    returnType::AbstractString
end # struct NoArgsFunctionNode

# Second constructor of NoArgsFunctionNode struct.
NoArgsFunctionNode(symbol, func) = NoArgsFunctionNode(symbol, func, "nothing")

# Gets the value of the terminal node or executes the 0 arity-function of the node.
function eval(node::TerminalNode)
    if typeof(node) == NoArgsFunctionNode
        eval(node.func)()
    else
        node.value
    end
end

# Gets the identifier of the node.
function getSymbol(node::Node)
    if typeof(node) == ConstantNode
        node.value
    else
        node.symbol
    end
end

# Gets the type of the node.
function getType(node::Node)
    if typeof(node) == FunctionNode || typeof(node) == NoArgsFunctionNode
        node.returnType
    else
        typeof(node.value)
    end
end
