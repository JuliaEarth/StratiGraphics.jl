using StratiGraphics
using Meshes
using GeoStatsBase
using ReferenceTests, ImageIO
using Test, Plots, Random
gr(size=(600,400))

# workaround for GR warnings
ENV["GKSwstype"] = "100"

# environment settings
isCI = "CI" ∈ keys(ENV)
islinux = Sys.islinux()
visualtests = !isCI || (isCI && islinux)
datadir = joinpath(@__DIR__,"data")

include("dummysolver.jl")

@testset "StratiGraphics.jl" begin
  if visualtests
    rng    = MersenneTwister(2019)
    proc   = GeoStatsProcess(Dummy())
    env    = Environment(rng, [proc, proc], [0.5 0.5; 0.5 0.5], ExponentialDuration(rng, 1.0))
    record = simulate(env, LandState(zeros(50,50)), 10)
    strata = Strata(record)

    @test_reference "data/strata.png" plot(strata)

    for (i, fillbase, filltop) in [(1, NaN, NaN), (2, 0, NaN), (3, 0, 0)]
      rng  = MersenneTwister(2019)
      proc = GeoStatsProcess(Dummy())
      env  = Environment(rng, [proc, proc], [0.5 0.5; 0.5 0.5], ExponentialDuration(rng, 1.0))
      prob = SimulationProblem(CartesianGrid(50,50,20), :strata => Float64, 3)
      solv = StratSim(:strata => (environment=env, fillbase=fillbase, filltop=filltop))
      sol  = solve(prob, solv)
      plts = map(sol) do real
        R = asarray(real, :strata)
        heatmap(rotr90(R[1,:,:]))
      end
      @test_reference "data/voxel$i.png" plot(plts..., layout=(3,1))
    end
  end
end
