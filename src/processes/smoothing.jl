# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    SmoothingProcess(σ=3)

A smoothing process (i.e. Gaussian filter) with `σ` parameter.
"""
struct SmoothingProcess <: TimelessProcess
  σ::Float64
end

SmoothingProcess() = SmoothingProcess(3.0)

evolve!(land::Matrix, proc::SmoothingProcess) =
  imfilter!(land, land, centered(Kernel.gaussian(proc.σ)), "replicate")
