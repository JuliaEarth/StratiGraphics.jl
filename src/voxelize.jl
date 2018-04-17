# ------------------------------------------------------------------
# Copyright (c) 2017, Júlio Hoffimann Mendes <juliohm@stanford.edu>
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

function voxelize(stacked::Vector{<:Matrix}, nz=100)
  # initial landscape
  init  = copy(stacked[1])
  init -= minimum(init[.!isnan.(init)])

  # surface type and dimensions
  T = eltype(init)
  nx, ny = size(init)

  # estimate bulk sediment
  thickness = diff(stacked)

  # handle NaNs
  init[isnan.(init)] = zero(T)
  for t=1:length(thickness)
    thick = thickness[t]
    thick[isnan.(thick)] = zero(T)
    @assert all(thick .≥ zero(T)) "negative thickness encountered, make sure surfaces were stacked"
  end

  # estimate maximum z coordinate
  zmax = maximum(init + sum(thickness))

  # build model layer by layer
  model = fill(T(NaN), nx, ny, nz)
  elevation = floor.(Int, (init/zmax)*nz)
  for t=1:length(thickness)
    thick = thickness[t]
    sediments = floor.(Int, (thick/zmax)*nz)
    for j=1:ny, i=1:nx
      for k=1:sediments[i,j]
        model[i,j,elevation[i,j]+k] = t
      end
    end
    elevation += sediments
  end

  model
end
