## Copyright (c) 2017, Júlio Hoffimann Mendes <juliohm@stanford.edu>
##
## Permission to use, copy, modify, and/or distribute this software for any
## purpose with or without fee is hereby granted, provided that the above
## copyright notice and this permission notice appear in all copies.
##
## THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
## WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
## MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
## ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
## WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
## ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
## OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

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