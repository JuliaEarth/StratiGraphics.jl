import GeoStatsBase: solvesingle

# define a dummy solver for testing
@simsolver Dummy begin end
function solvesingle(problem::SimulationProblem, covars::NamedTuple, ::Dummy, preproc)
  mactypeof = Dict(name(v) => mactype(v) for v in variables(problem))
  reals = map(covars.names) do var
    V = mactypeof[var]
    var => fill(one(V), nelms(domain(problem)))
  end
  Dict(reals)
end
