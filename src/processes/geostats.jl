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
  L = state.land

  # define 2D geostatistical problem
  domain  = RegularGrid{Float64}(size(L))
  problem = SimulationProblem(domain, :land => Float64, 1)

  # generate realization
  solution = solve(problem, proc.solver)
  Λ = solution[:land][1]

  # evolve landscape
  @. L = L + Δt * Λ

  nothing
end
