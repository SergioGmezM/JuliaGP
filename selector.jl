include("nodes.jl")
include("evaluator.jl")



abstract type SelectionOperator end


struct TournamentSelector <: SelectionOperator
    _k::Int64

    TournamentSelector(k) = 0 < k ? new(k) : error("The tournament size must be at least 1")
end

getTournamentSize(ts::TournamentSelector) = ts._k

function selectOne(ts::TournamentSelector, pop::Array{Array{Node}}, ev::Evaluator)
    nInd = length(pop) # Number of individuals of the population
    rndIndex = Int(trunc((rand() * nInd) + 1))

    best = pop[rndIndex]

    for i = 1:getTournamentSize(ts)
        rndIndex = Int(trunc((rand() * nInd) + 1))

        current = pop[rndIndex]

        best = compareFitness(ev, 1, current, best)
    end

    return best
end


function select(ts::TournamentSelector, pop::Array{Array{Node}}, ev::Evaluator)
    selected = Array{Array{Node}}(undef, 0)
    pop_size = length(pop)

    for i = 1:pop_size
        push!(selected, selectOne(ts, pop, ev))
        push!(selected, selectOne(ts, pop, ev))
    end

    return selected
end
