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

@testset "StratiGraphics.jl" begin
  # TODO
end
