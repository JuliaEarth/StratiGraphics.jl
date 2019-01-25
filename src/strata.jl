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

@recipe function f(strata::Strata)
  seriestype --> :surface
  colorbar --> :false
  for horizon in strata.horizons
    @series begin
      horizon
    end
  end
end
