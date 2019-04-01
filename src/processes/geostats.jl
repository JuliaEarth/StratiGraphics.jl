# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    PostProcess

A post-processing step on each generated 2D realization.
"""
abstract type PostProcess end

"""
    SmoothingProcess(kernelsize=3)

A smoothing process (i.e. Gaussian filter) with `kernelsize`.
"""
struct SmoothingProcess <: PostProcess
  kernelsize::Int
end

SmoothingProcess() = SmoothingProcess(3)

"""
    GeoStatsProcess(solver, [post])

Geostatistical process with simulation `solver` and `post`-processing
operation on each realization (default to `SmoothingProcess()`).
"""
struct GeoStatsProcess{S,P} <: Process
  solver::S
  post::P
end

GeoStatsProcess(solver) = GeoStatsProcess(solver, SmoothingProcess())

function evolve!(state::LandState, proc::GeoStatsProcess, Δt::Float64)
  # retrieve current landscape
  Lₒ = state.land

  # fill time duration with realizations
  nreal = clamp(round(Int, Δt), 1, typemax(Int))

  # define 2D geostatistical problem
  domain  = RegularGrid{Float64}(size(Lₒ))
  problem = SimulationProblem(domain, :land => Float64, nreal)

  # generate realizations
  solution = solve(problem, proc.solver)

  Ls = solution[:land]
  L  = Lₒ + sum(Ls)

  # update the state
  Lₒ .= L

  nothing
end
