# Node is the abstract type that will contain every node of the expression tree.
abstract type Node end

# FunctionNode represents a non-terminal node of the expression tree.
#   symbol: the character sequence that identifies the function node.
#   func: the actual function that will be executed for that function node.
#   arity: the number of parameters for the function, also, the number of
#   children of the function node.
struct FunctionNode <: Node
    symbol::AbstractString
    func::Symbol
    arity::Int8
    conmutative::Bool

    FunctionNode(symbol, func, arity, conmutative) = arity > 0 ? new(symbol, func, arity, conmutative) : error("A function with no arguments is not a function node: $symbol")
end # struct FunctionNode

# Second constructor of FunctionNode struct.
FunctionNode(symbol, func, arity) = FunctionNode(symbol, func, arity, true)

# Gets the arity of a given function node.
getArity(node::FunctionNode) = node.arity

# Checks if the operation is conmutative.
isConmutative(node::FunctionNode) = node.conmutative

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
struct NoArgsFunctionNode <: TerminalNode
    symbol::AbstractString
    func::Symbol
end # struct NoArgsFunctionNode

# Gets the value of the terminal node or executes the 0 arity-function of the node.
function eval(x::TerminalNode)
    if typeof(x) == NoArgsFunctionNode
        eval(x.func)()
    else
        x.value
    end
end

# Gets the identifier of the node.
function getSymbol(x::Node)
    if typeof(x) == ConstantNode
        x.value
    else
        x.symbol
    end
end
