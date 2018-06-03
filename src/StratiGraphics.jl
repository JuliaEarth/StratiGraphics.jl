# ------------------------------------------------------------------
# Copyright (c) 2017, Júlio Hoffimann Mendes <juliohm@stanford.edu>
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

# we cannot enable precompilation due to ImageQuilting.jl
__precompile__(false)

module StratiGraphics

using ImageQuilting
using ImageFiltering: imfilter, Kernel
using Distributions: Exponential, Uniform, wsample
using ProgressMeter: Progress, next!
using JuMP, ECOS

include("datatypes.jl")
include("flowprocs.jl")
include("landsim.jl")
include("landstack.jl")
include("landmatch.jl")
include("voxelize.jl")

export
  # flow processes
  QuiltProcess,
  evolve,

  # functions
  landsim,
  landstack!,
  landmatch!,
  voxelize,

  # data types
  Well

end
