# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENCE in the project root.
# ------------------------------------------------------------------

module StratiGraphics

using Meshes
using GeoStatsBase

using ImageFiltering: Kernel, centered, imfilter!
using Distributions: Exponential, Uniform, wsample
using RecipesBase

import GeoStatsBase: preprocess, solvesingle

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

  # timeless processes
  GeoStatsProcess,
  SmoothingProcess,
  AnalyticalProcess,
  SequentialTimelessProcess,

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
