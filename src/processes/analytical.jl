# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

struct AnalyticalProcess <: TimelessProcess
  func::Function
end

function evolve!(land::Matrix, proc::AnalyticalProcess)
  @. land = proc.func(land)
  nothing
end
