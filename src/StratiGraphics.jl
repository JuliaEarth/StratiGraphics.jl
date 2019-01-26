# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

module StratiGraphics

using GeoStatsBase
using GeoStatsDevTools
import GeoStatsBase: preprocess, solve_single

using Distributions: Exponential, Uniform, wsample
using RecipesBase

include("environment.jl")
include("processes.jl")
include("durations.jl")
include("state.jl")
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
  State,
  flow,
  land,

  # geological record
  Record,

  # stratigraphy
  Strata,
  voxelize,

  # GeoStats.jl API
  StratiSim

end
