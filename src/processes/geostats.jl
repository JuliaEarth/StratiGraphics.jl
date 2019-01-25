# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    GeoStatsProcess(solver)

A geostatistical process with given `solver`.
"""
struct GeoStatsProcess{S<:AbstractSimulationSolver} <: Process
  solver::S
end

function evolve!(state, proc::GeoStatsProcess, Δt::Float64)
  @assert Δt > 0 "invalid time period"

  # retrieve state info
  Fₒ, Lₒ = flow(state), land(state)

  # fill time duration with realizations
  nreal = clamp(round(Int, Δt), 1, typemax(Int))

  # define 2D geostatistical problem
  domain  = RegularGrid{Float64}(size(Fₒ))
  problem = SimulationProblem(domain, :flow => Float64, nreal)

  # generate realizations
  solution = solve(problem, proc.solver)
  reals    = digest(solution)

  Fs = reals[:flow]
  F  = Fs[end]
  L  = Lₒ + sum(Fs)

  # update the state
  Fₒ .= F; Lₒ .= L

  nothing
end
