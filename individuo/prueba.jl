include("JuliaGP.jl")

include("functions.jl")

# Se define la función de fitness que utilizará el sistema
# la función siempre debe recibir como argumentos el objeto Fitness
# y un individuo en forma de cadena de caracteres
function myFunction(fitness::Fitness, individual::String)::Float64

    # Para obtener el individuo, se utiliza Meta.parse para pasar de cadena
    # a expresión interpretable por Julia
    expr = Meta.parse(individual)
    result = Inf

    # El fitness se mantendrá en infinito si la expresión es inválida
    try
        # Para obtener el valor de la expresión, se utiliza eval
        result = abs(eval(expr) - fitness.values[1]) # en este caso no se me ocurre para qué usar weights
    catch
    end

    return result
end

gen = Generator(50, 3, "grow") # Creamos el generador de la población
fitness = Fitness((50.0,), (-1,)) # Creamos el fitness que utilizará el sistema
ev = Evaluator(fitness, myFunction) # Creamos el evaluador del sistema con nuestra función de evaluación

gp = JuliaGP(gen, ev) # Creamos el sistema de GP con las herramientas que hemos creado

# Establecemos los conjuntos de funciones y terminales
readFunctions(gp, "functionSet.txt")
readTerminals(gp, "terminalSet.txt")

"""for op in gp.functionSet
    if getArity(op) == 1
        println("\$(getSymbol(op)) --> \$(eval(op, 2))")
    elseif getArity(op) == 2
        println("\$(getSymbol(op)) --> \$(eval(op, 2, 3))")
    end
end

for term in gp.terminalSet
    if eval(term) != nothing
        println("\$(getSymbol(term)) --> \$(eval(term))")
    end
end"""

# Generamos una población
pop = gen_pop(gp)

bestFitness = Inf
bestInd = pop[1]
pos = 1

# Para cada individuo de la población, evaluamos su fitness y nos vamos
# quedando con el mejor de todos
for i = 1:length(pop)

    fit = evaluate(gp, pop[i])

    print("individuo $i: ")
    for node in pop[i]
        print("$(getSymbol(node)) ")
    end
    print("\n")

    if bestFitness > fit
        global bestFitness = fit
        global bestInd = pop[i]
        global pos = i
    end
end

# Imprimimos el mejor
print("\n\nMEJOR INDIVIDUO:\nindividuo $pos: ")
for node in bestInd
    print("$(getSymbol(node)) ")
end
println("\nFitness: $bestFitness")
