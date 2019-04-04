# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    Process

A geological process of evolution.
"""
abstract type Process end

"""
    evolve!(state, proc, Δt)

Evolve the `state` with process `proc` for a time period `Δt`.
"""
evolve!(state, proc, Δt::Float64) = error("not implemented")

"""
    TimelessProcess

A geological process implemented without the notion of time.
"""
abstract type TimelessProcess <: Process end

"""
    evolve!(land, proc)

Evolve the `land` with timeless process `proc`.
"""
evolve!(land::Matrix, proc::TimelessProcess) = error("not implemented")

"""
    evolve!(land, proc, Δt)

Evolve the `land` with timeless process `proc` for a time period `Δt`.
"""
function evolve!(land::Matrix, proc::TimelessProcess, Δt::Float64)
  t = mean(land)
  evolve!(land, proc)
  @. land = t + Δt + land
  nothing
end

"""
    evolve!(state, proc, Δt)

Evolve the landscape `state` with timeless process `proc` for a time period `Δt`.
"""
evolve!(state::LandState, proc::TimelessProcess, Δt::Float64) =
  evolve!(state.land, proc, Δt)

#------------------
# IMPLEMENTATIONS
#------------------
include("processes/geostats.jl")
include("processes/smoothing.jl")
include("processes/sequential.jl")
include("processes/analytical.jl")
