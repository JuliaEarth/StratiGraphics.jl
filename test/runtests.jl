using GeoStatsBase
using GeoStatsDevTools
using StratiGraphics
using Plots; gr()
using VisualRegressionTests
using Test, Pkg, Random

# environment settings
islinux = Sys.islinux()
istravis = "TRAVIS" ∈ keys(ENV)
datadir = joinpath(@__DIR__,"data")
visualtests = !istravis || (istravis && islinux)
if !istravis
  Pkg.add("Gtk")
  using Gtk
end

include("dummysolver.jl")

@testset "StratiGraphics.jl" begin
  if visualtests
    Random.seed!(2019)
    env = Environment([Dummy(),Dummy()], [0.5 0.5; 0.5 0.5], ExponentialDuration(1.0))
    record = simulate(env, LandState(zeros(50,50)), 10)
    strata = Strata(record)

    @plottest plot(strata) joinpath(datadir,"strata.png") !istravis

    Random.seed!(2019)
    problem = SimulationProblem(RegularGrid{Float64}(50,50,20), :strata => Float64, 3)
    solver = StratSim(:strata => (environment=env,))
    solution = solve(problem, solver)
    reals = digest(solution)[:strata]

    @plottest begin
      plts = [heatmap(rotr90(real[1,:,:])) for real in reals]
      plot(plts..., layout=(3,1))
    end joinpath(datadir,"voxel.png") !istravis
  end
end
