# ------------------------------------------------------------------
# Copyright (c) 2017, Júlio Hoffimann Mendes <juliohm@stanford.edu>
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

function landsim(images::Vector{<:Matrix};
                 weights=ones(length(images)),
                 DEM=zeros(size(images[1])), nevents=5, eventrate=1.,
                 time2thick=1., smoothwindow=3, upliftrate=eps(),
                 tplsizex=30, tplsizey=30,
                 fold=false, foldrate=1., foldlocation=70, foldwidth=8,
                 nreal=1, showprogress=false)
  # sanity checks
  @assert length(Set(size.(images))) == 1 "images must have the same size"
  @assert length(weights) == length(images) "number of weights must match number of images"
  @assert all(weights .> 0) "image weights must be positive"
  @assert DEM isa Matrix{Float64} "DEM must be a 2D array of Float64"
  @assert size(DEM) == size(images[1]) "DEM must have the same size as training images"
  @assert nevents ≥ 0 "number of events must be non-negative"

  # image shape
  TI     = images[1]
  NaNTI  = isnan.(TI)
  nx, ny = size(TI)

  # handle NaN in initial landscape
  DEM[NaNTI] = NaN

  # hard constraints
  hdata = HardData()
  for idx in find(NaNTI)
    i, j = ind2sub((nx,ny), idx)
    push!(hdata, (i,j,1)=>NaN)
  end

  # soft constraints
  AUX1 = [i/nx for i=1:nx, j=1:ny, k=1:1]
  AUX2 = [j/ny for i=1:nx, j=1:ny, k=1:1]
  sdata = [(AUX1, AUX1), (AUX2, AUX2)]

  # growing fold (Bufe's experiment setup)
  if fold
    foldmask = zeros(DEM)
    foldmask[foldlocation,:] = 1.
    foldmask = imfilter(foldmask, Kernel.gaussian(foldwidth))
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
      imgID = wsample(1:length(images), weights)
      image = images[imgID]

      # sample event duration
      ΔT = rand(Exponential(1/eventrate))

      # sample uplift rate
      U = rand(Uniform(0,2*upliftrate))

      # generate flow pattern and sediment mask
      TI = reshape(image, size(image)..., 1)
      reals = iqsim(TI, tplsizex, tplsizey, 1, size(TI)...,
                    hard=hdata, soft=sdata, path=:random)
      sedmask = imfilter(reals[1][:,:,1], Kernel.gaussian(smoothwindow))

      # deposit sediments
      landscape += sedmask * time2thick * ΔT

      # uplift basin
      landscape -= U * ΔT

      # Bufe's experiment setup
      fold && (landscape += foldmask * foldrate * ΔT)

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
