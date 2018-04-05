# ------------------------------------------------------------------
# Copyright (c) 2017, Júlio Hoffimann Mendes <juliohm@stanford.edu>
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

function landsim(training_images::Vector{BitMatrix};
                 image_weights=ones(length(training_images)),
                 DEM=nothing, nevents=1, eventrate=1.,
                 time2thick=1., smoothwindow=3, upliftrate=1.,
                 tplsizex=30, tplsizey=30,
                 bufesetup=false, brate=1., blocation=70, bwidth=8,
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
  AUX1 = [i/nx for i=1:nx, j=1:ny, k=1:1]
  AUX2 = [j/ny for i=1:nx, j=1:ny, k=1:1]
  sdata = [(AUX1, AUX1), (AUX2, AUX2)]

  # Bufe's experiment setup
  if bufesetup
    bmask = zeros(DEM)
    bmask[blocation,:] = 1
    bmask = imfilter(bmask, Kernel.gaussian(bwidth))
  end

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
      imgID = wsample(1:length(training_images), image_weights)
      training_image = training_images[imgID]

      # sample event duration
      ΔT = rand(Exponential(1/eventrate))

      # sample uplift rate
      U = rand(Uniform(0,2*upliftrate))

      # generate flow pattern and sediment mask
      TI = reshape(training_image, size(training_image)..., 1)
      reals = iqsim(TI, tplsizex, tplsizey, 1, size(TI)..., soft=sdata, path=:random)
      flow_pattern = reals[1][:,:,1]
      sedmask = imfilter(flow_pattern, Kernel.gaussian(smoothwindow))

      # deposit sediments
      landscape += sedmask * time2thick * ΔT

      # uplift basin
      landscape -= U * ΔT

      # Bufe's experiment setup
      bufesetup && (landscape += bmask * brate * ΔT)

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
