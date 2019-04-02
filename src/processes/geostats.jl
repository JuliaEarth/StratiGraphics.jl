# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    GeoStatsProcess(solver, [post])

Geostatistical process with simulation `solver` and `post`-processing
operation on each realization (default to `NoProcess()`).
"""
struct GeoStatsProcess{S,P} <: Process
  solver::S
  post::P
end

GeoStatsProcess(solver) = GeoStatsProcess(solver, NoProcess())

function evolve!(state::LandState, proc::GeoStatsProcess, Δt::Float64)
  # retrieve current landscape
  L = state.land

  # define 2D geostatistical problem
  domain  = RegularGrid{Float64}(size(L))
  problem = SimulationProblem(domain, :land => Float64, 1)

  # generate realization
  solution = solve(problem, proc.solver)
  Λ = solution[:land][1]

  # post-process realization
  transform!(Λ, proc.post)

  # evolve landscape
  @. L = L + Δt * Λ

  nothing
end

######################
### POST PROCESSES ###
######################

"""
    PostProcess

A post-processing step on each generated 2D realization.
"""
abstract type PostProcess end

"""
    transform!(realization, post)

Transform `realization` in place with `post`-processing step.
"""
transform!(realization, post::PostProcess) = error("not implemented")

"""
    NoProcess()

A dummy post-processing step that does nothing.
"""
struct NoProcess <: PostProcess end

transform!(realization, post::NoProcess) = nothing

"""
    SmoothingProcess(σ=3)

A smoothing process (i.e. Gaussian filter) with `σ` parameter.
"""
struct SmoothingProcess <: PostProcess
  σ::Float64
end

SmoothingProcess() = SmoothingProcess(3.0)

transform!(realization, post::SmoothingProcess) =
  imfilter!(realization, realization, centered(Kernel.gaussian(post.σ)), "replicate")
