# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    SequentialTimelessProcess

A a sesquence of `first` and `second` timeless processes.
"""
struct SequentialTimelessProcess{P} <: TimelessProcess
  first::P
  second::P
end

function evolve!(land::Matrix, proc::SequentialTimelessProcess)
  evolve!(land, proc.first)
  evolve!(land, proc.second)
end

→(first::TimelessProcess, second::TimelessProcess) =
  SequentialTimelessProcess(first, second)
