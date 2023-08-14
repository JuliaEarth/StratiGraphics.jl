import GeoStatsBase: solvesingle

# define a dummy solver for testing
@simsolver Dummy begin end
function solvesingle(problem::SimulationProblem, covars::NamedTuple, ::Dummy, preproc)
  reals = map(collect(covars.names)) do var
    V = variables(problem)[var]
    var => fill(one(V), nelements(domain(problem)))
  end
  Dict(reals)
end
