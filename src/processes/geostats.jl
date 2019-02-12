# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

function evolve!(state::LandState, proc::AbstractSimulationSolver, Δt::Float64)
  # retrieve current landscape
  Lₒ = state.land

  # fill time duration with realizations
  nreal = clamp(round(Int, Δt), 1, typemax(Int))

  # define 2D geostatistical problem
  domain  = RegularGrid{Float64}(size(Lₒ))
  problem = SimulationProblem(domain, :land => Float64, nreal)

  # generate realizations
  solution = solve(problem, proc)
  reals    = digest(solution)

  Ls = reals[:land]
  L  = Lₒ + sum(Ls)

  # update the state
  Lₒ .= L

  nothing
end
