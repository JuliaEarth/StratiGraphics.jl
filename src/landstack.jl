# ------------------------------------------------------------------
# Copyright (c) 2017, Júlio Hoffimann Mendes <juliohm@stanford.edu>
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

function landstack!(landscapes::Vector{<:Matrix})
  # erode all landscapes backward in time
  for t=length(landscapes):-1:2
    Lt = landscapes[t]
    Lp = landscapes[t-1]
    erosion = Lp .> Lt
    Lp[erosion] = Lt[erosion]
  end

  nothing
end
