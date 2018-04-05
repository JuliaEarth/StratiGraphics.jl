# ------------------------------------------------------------------
# Copyright (c) 2017, Júlio Hoffimann Mendes <juliohm@stanford.edu>
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

# we cannot enable precompilation due to ImageQuilting.jl
__precompile__(false)

module StratiGraphics

using Images: imfilter, Kernel
using ImageQuilting
using Distributions: Exponential, Uniform, wsample
using ProgressMeter: Progress, next!
using JuMP, ECOS

include("datatypes.jl")
include("landsim.jl")
include("landstack.jl")
include("landmatch.jl")
include("voxelize.jl")

export
  # functions
  landsim,
  landstack!,
  landmatch!,
  voxelize,

  # data types
  Well

end
