# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    State(flow, land)

A geological state consisting of `flow` and `land` maps.
"""
struct State
  flow::Matrix{Float64}
  land::Matrix{Float64}
end

# accessor functions
flow(state::State) = state.flow
land(state::State) = state.land

@recipe function f(state::State, attr=:land)
  aspect_ratio --> :equal
  colorbar --> :false
  if attr == :land
    seriestype --> :surface
    state.land
  elseif attr == :flow
    seriestype --> :heatmap
    seriescolor --> :kdc_r
    state.flow
  else
    @error "invalid attribute"
  end
end
