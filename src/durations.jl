# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENCE in the project root.
# ------------------------------------------------------------------

struct ExponentialDuration{RNG}
  rng::RNG
  λ::Float64
end

ExponentialDuration(λ) = ExponentialDuration(Random.default_rng(), λ)

(p::ExponentialDuration)(t) = rand(p.rng, Exponential(1 / p.λ))

struct UniformDuration{RNG}
  rng::RNG
  a::Float64
  b::Float64
end

UniformDuration(a, b) = UniformDuration(Random.default_rng(), a, b)

(p::UniformDuration)(t) = rand(p.rng, Uniform(p.a, p.b))
