# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

module StratiGraphics

using GeoStatsBase
using GeoStatsDevTools
import GeoStatsBase: preprocess, solve_single

using Distributions: Exponential, Uniform, wsample
using RecipesBase

include("state.jl")
include("processes.jl")
include("durations.jl")
include("environment.jl")
include("record.jl")
include("strata.jl")
include("geostats.jl")

export
  # geological environment
  Environment,
  simulate,

  # duration processes
  ExponentialDuration,
  UniformDuration,

  # geological state
  LandState,

  # geological record
  Record,

  # stratigraphy
  Strata,
  voxelize,

  # GeoStats.jl API
  StratSim

end
