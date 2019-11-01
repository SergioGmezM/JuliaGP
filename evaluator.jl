# Fitness represents the values desired for the individuals of a population.
#   values: the values pursued by the individuals.
#   weights: each element indicates if the fitness value that corresponds to it
#   is to be minimized or maximized.
struct Fitness
    _values::Tuple
    _weights::Tuple

    Fitness(values, weights) = length(values) == length(weights) ? new(values, weights) : error("Each weight must correspond to each value of fitness")
end # struct Fitness

# Gets the fitness value specified by the given index
function getFitnessValue(fitness::Fitness, i::Int64)
    if 0 < i <= length(fitness._values)
        fitness._values[i]
    else
        error("The specified index must be within the range of fitness values")
    end
end

# Gets the fitness weight specified by the given index
function getFitnessWeights(fitness::Fitness, i::Int64)
    if 0 < i <= length(fitness._weights)
        fitness._weights[i]
    else
        error("The specified index must be within the range of fitness weights")
    end
end

# Evaluator represents the way that the system is going to evaluate the
# individuals of a population.
#   fitness: the fitness values and weights that are going to be used.
#   fitnessFunction: a user-defined function that takes an individual and the
#   fitness of the evaluator, and determines how fit it is.
struct Evaluator
    _fitness::Fitness
    _fitnessFunction

    Evaluator(fitness, fitnessFunction) = typeof(fitnessFunction(fitness, "")) <: Number ? new(fitness, fitnessFunction) : error("Fitness function must return a numerical value")
end # struct Evaluator
