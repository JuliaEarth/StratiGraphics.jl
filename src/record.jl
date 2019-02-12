# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    Record(states)

A geological record of geological `states`.
"""
struct Record{S<:State}
  states::Vector{S}
end

Base.getindex(record::Record, ind) = getindex(record.states, ind)
Base.length(record::Record) = length(record.states)
Base.push!(record::Record, state) = push!(record.states, state)
Base.iterate(record::Record, state=1) = iterate(record.states, state)
