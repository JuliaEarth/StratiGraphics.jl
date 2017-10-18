## Copyright (c) 2017, Júlio Hoffimann Mendes <juliohm@stanford.edu>
##
## Permission to use, copy, modify, and/or distribute this software for any
## purpose with or without fee is hereby granted, provided that the above
## copyright notice and this permission notice appear in all copies.
##
## THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
## WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
## MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
## ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
## WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
## ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
## OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

function landmatch!(landscapes::Vector{<:Matrix}, wells::AbstractVector{Well};
                    tol=.1, showprogress=false)
  # retrieve dimensions
  nx, ny = size(landscapes[1])
  nlandscapes = length(landscapes)

  # JuMP model
  m = Model(solver=ECOSSolver(verbose=false))

  # input landscape (data matrix)
  E = Array{Float64}(nx, ny)

  # optimization variables
  @variable(m, L[1:nx,1:ny])
  @variable(m, t[1:nx,1:ny])

  # convex problem in epigraph form
  @objective(m, Min, sum(t))
  @constraint(m, [i=1:nx,j=1:ny], t[i,j] ≥ 0)
  @constraint(m, upperbound[i=1:nx,j=1:ny], L[i,j] - E[i,j] ≤ t[i,j])
  @constraint(m, lowerbound[i=1:nx,j=1:ny], E[i,j] - L[i,j] ≤ t[i,j])

  # smoothness constraints on 3rd derivative
  @constraint(m, [i=3:nx-1,j=1:ny], L[i+1,j] - 3L[i,j] + 3L[i-1,j] - L[i-2,j] ≤  tol)
  @constraint(m, [i=3:nx-1,j=1:ny], L[i+1,j] - 3L[i,j] + 3L[i-1,j] - L[i-2,j] ≥ -tol)
  @constraint(m, [i=1:nx,j=3:ny-1], L[i,j+1] - 3L[i,j] + 3L[i,j-1] - L[i,j-2] ≤  tol)
  @constraint(m, [i=1:nx,j=3:ny-1], L[i,j+1] - 3L[i,j] + 3L[i,j-1] - L[i,j-2] ≥ -tol)

  # show progress and estimated time duration
  showprogress && (progress = Progress(nlandscapes, color=:black))

  # loop over landscapes
  for i=1:nlandscapes
    # initialize input landscape
    E = landscapes[i]

    # update RHS of LP problem
    JuMP.setRHS.(upperbound,  E)
    JuMP.setRHS.(lowerbound, -E)

    # update well constraints
    # TODO

    # solve
    status = solve(m)

    if status == :Optimal
      # update landscape
      landscapes[i] = getvalue(L)
    else
      warn("Failed to find optimal value")
    end

    # update progress bar
    showprogress && next!(progress)
  end

  nothing
end
