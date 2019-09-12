# Fitness represents the values desired for the individuals of a population.
#   values: the values pursued by the individuals.
#   weights: each element indicates if the fitness value that corresponds to it
#   is to be minimized or maximized.
struct Fitness
    values::Tuple
    weights::Tuple

    Fitness(values, weights) = length(values) == length(weights) ? new(values, weights) : error("Each weight must correspond to each value of fitness")
end # struct Fitness

# Evaluator represents the way that the system is going to evaluate the
# individuals of a population.
#   fitness: the fitness values and weights that are going to be used.
#   fitnessFunction: a user-defined function that takes an individual and the
#   fitness of the evaluator, and determines how fit it is.
struct Evaluator
    fitness::Fitness
    fitnessFunction

    Evaluator(fitness, fitnessFunction) = typeof(fitnessFunction(fitness, "")) == Number ? new(fitness, fitnessFunction) : error("Fitness function must return a numerical value")
end # struct Evaluator
