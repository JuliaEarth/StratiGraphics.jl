# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENCE in the project root.
# ------------------------------------------------------------------

module StratiGraphics

using ImageFiltering
using Distributions
using Random

include("state.jl")
include("processes.jl")
include("durations.jl")
include("environment.jl")
include("record.jl")
include("strata.jl")

export
  # geological environment
  Environment,
  simulate,

  # timeless processes
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
  voxelize

end
