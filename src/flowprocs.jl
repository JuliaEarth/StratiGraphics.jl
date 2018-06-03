# ------------------------------------------------------------------
# Copyright (c) 2018, Júlio Hoffimann Mendes <juliohm@stanford.edu>
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

abstract type FlowProcess end

struct QuiltProcess <: FlowProcess
  images::Vector{Matrix}
  weights::Vector{Float64}
  lambda::Float64
end

function evolve(p::QuiltProcess, nsteps::Int)
  simulated = 0
  result = []

  while simulated < nsteps
    # sample event duration
    ΔT = rand(Exponential(1/p.lambda))

    # convert real time to time steps
    nreal = clamp(round(Int, ΔT), 1, nsteps - simulated)

    img = wsample(p.images, p.weights)
    simg = imfilter(img, Kernel.gaussian(3))

    TI = reshape(img, size(img)..., 1)

    nx, ny, nz = size(TI)
    aux₁ = reshape(simg, size(simg)..., 1)
    aux₂ = [i/nx for i in 1:nx, j in 1:ny, k=1:nz]
    soft = [(aux₁,aux₁), (aux₂,aux₂)]

    reals = iqsim(TI, 20, 20, 1, size(TI)...,
                  overlapx=1/4, overlapy=1/4,
                  soft=soft, path=:random,
                  nreal=nreal)

    append!(result, [real[:,:,1] for real in reals])
    simulated += nreal
  end

  result
end

#function Base.start(p::QuiltProcess)
  #img = p.imgs[1]
  #simg = imfilter(img, Kernel.gaussian(3))
  #reshape(simg, size(simg)..., 1), 1
#end

#function Base.next(p::QuiltProcess, state)
  #aux, count = state

  #img = p.imgs[count % length(p.imgs) + 1]
  #simg = imfilter(img, Kernel.gaussian(3))

  #TI = reshape(img, size(img)..., 1)

  #soft = [(aux,aux),(p.vaux,p.vaux)]

  #reals = iqsim(TI, 20, 20, 1, size(TI)...,
                #overlapx=1/4, overlapy=1/4,
                #soft=soft, path=:random)

  #newimg = reals[1][:,:,1]

  #newimg, (reshape(simg, size(simg)..., 1), count + 1)
#end

#function Base.done(p::QuiltProcess, state)
  #aux, count = state
  #count == p.length + 1
#end
