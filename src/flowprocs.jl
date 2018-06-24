# ------------------------------------------------------------------
# Copyright (c) 2018, Júlio Hoffimann Mendes <juliohm@stanford.edu>
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

abstract type FlowProcess end

struct QuiltProcess <: FlowProcess
  images::Vector{Matrix}
  transition::Matrix{Float64}
  lambda::Float64
end

function evolve(p::QuiltProcess, nsteps::Int)
  # sample state at random
  N = length(p.images)
  ind = rand(1:N)

  result = []
  simulated = 0
  while simulated < nsteps
    # transition to a new state
    ind = wsample(1:N, p.transition[ind,:])

    # sample event duration
    ΔT = rand(Exponential(1/p.lambda))

    # convert real time to time steps
    nreal = clamp(round(Int, ΔT), 1, nsteps - simulated)

    img = p.images[ind]
    simg = imfilter(img, Kernel.gaussian(3))

    TI  = reshape(img, size(img)..., 1)
    aux = reshape(simg, size(simg)..., 1)

    reals = iqsim(TI, 20, 20, 1, size(TI)...,
                  overlapx=1/4, overlapy=1/4,
                  soft=[(aux,aux)], path=:random,
                  nreal=nreal)

    append!(result, [real[:,:,1] for real in reals])
    simulated += nreal
  end

  result
end
