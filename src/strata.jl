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

function Strata(record::Record{LandState}, stack=:erosional)
  # land maps for all states in record
  horizons = [state.land for state in record]

  if stack == :erosional
    # erode land maps backward in time
    for t=length(horizons):-1:2
      Lt = horizons[t]
      Lp = horizons[t-1]
      erosion = Lp .> Lt
      Lp[erosion] = Lt[erosion]
    end
  end

  if stack == :depositional
    # deposit sediments forward in time
    for t=1:length(horizons)-1
      Lt = horizons[t]
      Lf = horizons[t+1]
      nodeposit = Lf .≤ Lt
      Lf[nodeposit] = Lt[nodeposit]
    end
  end

  Strata(horizons)
end

function voxelize(strata::Strata, nz::Int; fillbase=NaN, filltop=NaN)
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

  # voxel model
  model = fill(NaN, nx, ny, nz)

  # fill model base
  if !isnan(fillbase)
    for j=1:ny, i=1:nx
      for k=1:elevation[i,j]
        model[i,j,k] = fillbase
      end
    end
  end

  # add layers to model
  for t=1:length(thickness)
    thick = thickness[t]
    sediments = floor.(Int, (thick/zmax)*nz)
    for j=1:ny, i=1:nx
      for k=1:sediments[i,j]
        model[i,j,elevation[i,j]+k] = t
      end
    end
    elevation .+= sediments
  end

  # fill model top
  if !isnan(filltop)
    for j=1:ny, i=1:nx
      for k=elevation[i,j]+1:nz
        model[i,j,k] = filltop
      end
    end
  end

  model
end

@recipe function f(strata::Strata)
  aspect_ratio --> :equal
  seriestype --> :surface
  colorbar --> false
  for horizon in strata.horizons
    @series begin
      horizon
    end
  end
end
