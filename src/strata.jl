# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    Strata(record)

Stratigraphic model from geological `record`.
"""
struct Strata
  horizons::Vector{<:Matrix}
end

function Strata(record::Record)
  # land maps for all states in record
  horizons = land.(record)

  # erode land maps backward in time
  for t=length(horizons):-1:2
    Lt = horizons[t]
    Lp = horizons[t-1]
    erosion = Lp .> Lt
    Lp[erosion] = Lt[erosion]
  end

  Strata(horizons)
end

function voxelize(strata::Strata, nz=30)
  # retrieve horizons
  horizons = strata.horizons

  # initial land map
  init   = copy(horizons[1])
  init .-= minimum(init[.!isnan.(init)])
  nx, ny = size(init)

  # estimate bulk sediment
  thickness = diff(horizons)

  # handle NaNs
  init[isnan.(init)] .= 0.
  for t=1:length(thickness)
    thick = thickness[t]
    thick[isnan.(thick)] .= 0.
  end

  # estimate maximum z coordinate
  zmax = maximum(init + sum(thickness))

  # current elevation
  elevation = floor.(Int, (init/zmax)*nz)

  # initialize model with current elevation
  model = fill(NaN, nx, ny, nz)
  for j=1:ny, i=1:nx
    for k=1:elevation[i,j]
      model[i,j,k] = 1.0
    end
  end

  # add layers to model
  for t=1:length(thickness)
    thick = thickness[t]
    sediments = floor.(Int, (thick/zmax)*nz)
    for j=1:ny, i=1:nx
      for k=1:sediments[i,j]
        model[i,j,elevation[i,j]+k] = t + 1.0
      end
    end
    elevation .+= sediments
  end

  model
end

@recipe function f(strata::Strata)
  seriestype --> :surface
  colorbar --> :false
  for horizon in strata.horizons
    @series begin
      horizon
    end
  end
end
