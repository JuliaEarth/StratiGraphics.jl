# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

struct ExponentialDuration
  λ::Float64
end
(p::ExponentialDuration)(t) = rand(Exponential(1/p.λ))

struct UniformDuration
  a::Float64
  b::Float64
end
(p::UniformDuration)(t) = rand(Uniform(p.a,p.b))
