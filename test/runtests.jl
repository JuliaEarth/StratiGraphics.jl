using StratiGraphics
using GeoStatsBase
using Plots; gr(size=(600,400))
using ReferenceTests, ImageIO
using Test, Random

# workaround for GR warnings
ENV["GKSwstype"] = "100"

# environment settings
isCI = "CI" ∈ keys(ENV)
islinux = Sys.islinux()
visualtests = !isCI || (isCI && islinux)
datadir = joinpath(@__DIR__,"data")

# helper functions for visual regression tests
function asimage(plt)
  io = IOBuffer()
  show(io, "image/png", plt)
  seekstart(io)
  ImageIO.load(io)
end
macro test_ref_plot(fname, plt)
  esc(quote
    @test_reference $fname asimage($plt)
  end)
end

include("dummysolver.jl")

@testset "StratiGraphics.jl" begin
  if visualtests
    Random.seed!(2019)
    proc   = GeoStatsProcess(Dummy())
    env    = Environment([proc, proc], [0.5 0.5; 0.5 0.5], ExponentialDuration(1.0))
    record = simulate(env, LandState(zeros(50,50)), 10)
    strata = Strata(record)

    @test_ref_plot "data/strata.png" plot(strata)

    Random.seed!(2019)
    problem = SimulationProblem(RegularGrid(50,50,20), :strata => Float64, 3)
    solver₁ = StratSim(:strata => (environment=env,))
    solver₂ = StratSim(:strata => (environment=env,fillbase=0))
    solver₃ = StratSim(:strata => (environment=env,fillbase=0,filltop=0))
    solvers = [solver₁, solver₂, solver₃]

    solutions = [solve(problem, solver) for solver in solvers]
    snames = ["voxel1","voxel2","voxel3"]

    for (solution, sname) in zip(solutions, snames)
      reals = solution[:strata]
      plts = map(reals) do real
        R = reshape(real, 50, 50, 20)
        heatmap(rotr90(R[1,:,:]))
      end
      plt = plot(plts...,layout=(3,1))
      @test_ref_plot "data/$(sname).png" plt
    end
  end
end
