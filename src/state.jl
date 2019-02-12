# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    State

A geological state to be evolved by processes.
"""
abstract type State end

"""
    LandState(land)

A geological state consisting of a landscape map.
"""
struct LandState <: State
  land::Matrix{Float64}
end

@recipe function f(state::LandState)
  aspect_ratio --> :equal
  colorbar --> :false
  seriestype --> :surface
  state.land
end
