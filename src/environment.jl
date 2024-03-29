# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    Environment([rng,] processes, transitions, durations)

Geological environment with `processes`, `transitions` and `durations`.
"""
struct Environment{RNG}
  rng::RNG
  processes::Vector
  transitions::Matrix{Float64}
  durations::Any
end

Environment(processes, transitions, durations) = Environment(Random.default_rng(), processes, transitions, durations)

"""
    iterate(env, state=nothing)

Iterate the environment `env` producing processes and durations.
"""
function Base.iterate(env::Environment, state=nothing)
  # environment settings
  ps = env.processes
  P = env.transitions
  Δ = env.durations
  n = length(ps)

  # current state and time
  if state === nothing
    s, t = rand(env.rng, 1:n), 0
  else
    s, t = state
  end

  # process and duration
  proc = ps[s]
  Δt = Δ(t)

  # transition to a new state
  ss = wsample(env.rng, 1:n, view(P, s, :))
  tt = t + 1

  (proc, Δt), (ss, tt)
end

"""
    simulate(env, state, nepochs=10)

Simulate the geological environment `env` for a number of
epochs `nepochs` starting from a `state`.
"""
function simulate(env::Environment, state, nepochs::Int=10)
  s = deepcopy(state)
  record = Record([deepcopy(s)])
  for (proc, Δt) in Iterators.take(env, nepochs)
    evolve!(s, proc, Δt)
    push!(record, deepcopy(s))
  end
  record
end
