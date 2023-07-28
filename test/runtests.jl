using StratiGraphics
using Meshes
using GeoStatsBase
using Test, Random

include("dummy.jl")

@testset "StratiGraphics.jl" begin
  rng = MersenneTwister(2019)
  proc = GeoStatsProcess(Dummy())
  env = Environment(rng, [proc, proc], [0.5 0.5; 0.5 0.5], ExponentialDuration(rng, 1.0))
  record = simulate(env, LandState(zeros(50, 50)), 10)
  strata = Strata(record)

  for (i, fillbase, filltop) in [(1, NaN, NaN), (2, 0, NaN), (3, 0, 0)]
    rng = MersenneTwister(2019)
    proc = GeoStatsProcess(Dummy())
    env = Environment(rng, [proc, proc], [0.5 0.5; 0.5 0.5], ExponentialDuration(rng, 1.0))
    prob = SimulationProblem(CartesianGrid(50, 50, 20), :strata => Float64, 3)
    solv = StratSim(:strata => (environment=env, fillbase=fillbase, filltop=filltop))
    sol = solve(prob, solv)
  end
end
