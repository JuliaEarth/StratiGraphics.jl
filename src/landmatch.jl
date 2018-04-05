# ------------------------------------------------------------------
# Copyright (c) 2017, Júlio Hoffimann Mendes <juliohm@stanford.edu>
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

function landmatch!(landscapes::Vector{<:Matrix}, wells::AbstractVector{Well};
                    tol=.1, showprogress=false)
  # retrieve dimensions
  nx, ny = size(landscapes[1])
  nlandscapes = length(landscapes)

  # show progress and estimated time duration
  showprogress && (progress = Progress(nlandscapes, color=:black))

  # loop over landscapes
  for l=1:nlandscapes
    # input landscape
    E = landscapes[l]

    # JuMP model
    m = Model(solver=ECOSSolver(verbose=false))

    # optimization variables
    @variable(m, L[1:nx,1:ny])
    @variable(m, t[1:nx,1:ny])

    # convex problem in epigraph form
    @objective(m, Min, sum(t))
    @constraint(m, [i=1:nx,j=1:ny], t[i,j] ≥ 0)
    @constraint(m, [i=1:nx,j=1:ny], L[i,j] - E[i,j] ≤ t[i,j])
    @constraint(m, [i=1:nx,j=1:ny], E[i,j] - L[i,j] ≤ t[i,j])

    # smoothness constraints on 3rd derivative
    @constraint(m, [i=3:nx-1,j=1:ny], L[i+1,j] - 3L[i,j] + 3L[i-1,j] - L[i-2,j] ≤  tol)
    @constraint(m, [i=3:nx-1,j=1:ny], L[i+1,j] - 3L[i,j] + 3L[i-1,j] - L[i-2,j] ≥ -tol)
    @constraint(m, [i=1:nx,j=3:ny-1], L[i,j+1] - 3L[i,j] + 3L[i,j-1] - L[i,j-2] ≤  tol)
    @constraint(m, [i=1:nx,j=3:ny-1], L[i,j+1] - 3L[i,j] + 3L[i,j-1] - L[i,j-2] ≥ -tol)

    # well constraints
    for well in wells
      @constraint(m, L[well.coords...] == well.values[l])
    end

    # solve
    status = solve(m)

    # update landscape
    landscapes[l] = getvalue(L)

    # update progress bar
    showprogress && next!(progress)
  end

  nothing
end
