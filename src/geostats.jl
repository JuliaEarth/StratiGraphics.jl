# ------------------------------------------------------------------
# Licensed under the ISC License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    StratiSim(var₁=>param₁, var₂=>param₂, ...)

Stratigraphy simulation with Markov-Poisson sampling.

## Parameters

* `environment` - geological environment
* `state`       - initial geological state
* `nepochs`     - number of epochs (default to 10)

### References

Hoffimann 2018. *Morphodynamic analysis and statistical
synthesis of geormorphic data.*
"""
@simsolver StratiSim begin
  @param environment
  @param state = nothing
  @param nepochs = 10
end

function preprocess(problem::SimulationProblem, solver::StratiSim)
  # retrieve problem info
  pdomain = domain(problem)

  @assert ndims(pdomain) == 3 "solver implemented for 3D domain only"

  # result of preprocessing
  preproc = Dict{Symbol,NamedTuple}()

  for (var, V) in variables(problem)
    # get user parameters
    if var ∈ keys(solver.params)
      varparams = solver.params[var]
    else
      varparams = StratiSimParam()
    end

    # determine environment
    environment = varparams.environment

    # determine initial state
    if varparams.state ≠ nothing
      state = varparams.state
    else
      nx, ny, nz = size(pdomain)
      flow = zeros(nx, ny)
      land = zeros(nx, ny)
      state = State(flow, land)
    end

    # determine number of epochs
    nepochs = varparams.nepochs

    # save preprocessed input
    preproc[var] = (environment=environment, state=state, nepochs=nepochs)
  end

  preproc
end

function solve_single(problem::SimulationProblem, var::Symbol,
                      solver::StratiSim, preproc)
  # retrieve problem info
  pdomain = domain(problem)
  _, __, nz = size(pdomain)

  # get parameters for the variable
  environment, state, nepochs = preproc[var]

  # simulate the environment
  record = simulate(environment, state, nepochs)

  # build stratigraphy
  strata = Strata(record)

  # return voxel model
  vec(voxelize(strata, nz))
end
