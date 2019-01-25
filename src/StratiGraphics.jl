# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

module StratiGraphics

using GeoStatsBase
using GeoStatsDevTools

using Distributions: Exponential, Uniform, wsample
using RecipesBase

include("environment.jl")
include("processes.jl")
include("durations.jl")
include("state.jl")
include("record.jl")
include("strata.jl")

export
  # geological environment
  Environment,
  simulate,

  # geological processes
  GeoStatsProcess,

  # duration processes
  ExponentialDuration,
  UniformDuration,

  # geological state
  State,

  # geological record
  Record,

  # stratigraphy
  Strata

end
