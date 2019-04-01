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

#------------------
# IMPLEMENTATIONS
#------------------
include("processes/geostats.jl")
