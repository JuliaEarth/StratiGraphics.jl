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

function landsim(training_images::Vector{BitMatrix};
                 image_weights=ones(length(training_images)),
                 DEM=nothing, nevents=1, eventrate=1.,
                 time2thick=1., smoothwindow=3,
                 nreal=1, showprogress=false)

  # sanity checks
  @assert length(Set(size.(training_images))) == 1 "training images must have the same size"
  @assert length(image_weights) == length(training_images) "number of weights must match number of images"
  @assert all(image_weights .> 0) "image weights must be positive"
  if DEM ≠ nothing
    @assert DEM isa Matrix{Float64} "DEM must be a 2D array of Float64"
    @assert size(DEM) == size(training_images[1]) "DEM must have the same size as training images"
  end
  @assert nevents ≥ 0 "number of events must be non-negative"

  # grid size
  nx, ny = size(training_images[1])

  # initial landscape
  DEM == nothing && (DEM = zeros(Float64, nx, ny))

  # soft constraints
  AUX1 = Float64[i/nx for i=1:nx, j=1:ny, k=1:1]
  AUX2 = Float64[j/ny for i=1:nx, j=1:ny, k=1:1]
  sdata = [SoftData(AUX1, _ -> AUX1), SoftData(AUX2, _ -> AUX2)]

  # main output is a vector of 3D models
  realizations = []

  # show progress and estimated time duration
  showprogress && (progress = Progress(nreal, color=:black))

  for real=1:nreal
    # initialize landscape
    landscape = copy(DEM)
    landscapes = [copy(landscape)]

    # time loop
    for event=1:nevents
      # sample training image at random
      imgID = sample(1:length(training_images), weights(image_weights))
      training_image = training_images[imgID]

      # sample event duration
      ΔT = rand(Exponential(1/eventrate))

      # run forward model
      TI = reshape(training_image, size(training_image)..., 1)
      reals = iqsim(TI, 30, 30, 1, size(TI)..., soft=sdata)
      flow_pattern = reals[1][:,:,1]

      # deposit/erode
      ΔS = imfilter(flow_pattern, Kernel.gaussian(smoothwindow))
      ΔS *= time2thick * ΔT
      landscape += ΔS

      # save landscape and transition to a new flow pattern
      push!(landscapes, copy(landscape))
    end

    # save and continue
    push!(realizations, landscapes)

    # update progress bar
    showprogress && next!(progress)
  end

  realizations
end
