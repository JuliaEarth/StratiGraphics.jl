# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    SequentialTimelessProcess

A a sequence of `first` and `second` timeless processes.
"""
struct SequentialTimelessProcess{P1,P2} <: TimelessProcess
  first::P1
  second::P2
end

function evolve!(land::Matrix, proc::SequentialTimelessProcess)
  evolve!(land, proc.first)
  evolve!(land, proc.second)
end
