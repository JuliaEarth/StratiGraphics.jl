# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENCE in the project root.
# ------------------------------------------------------------------

"""
    StratSim(var₁=>param₁, var₂=>param₂, ...)

Stratigraphy simulation with Markov-Poisson sampling.

## Parameters

* `environment` - geological environment
* `state`       - initial geological state
* `stack`       - stacking scheme (:erosional or :depositional)
* `nepochs`     - number of epochs (default to 10)
* `fillbase`    - fill value for the bottom layer (default to `NaN`)
* `filltop`     - fill value for the top layer (default to `NaN`)

### References

Hoffimann 2018. *Morphodynamic analysis and statistical
synthesis of geormorphic data.*
"""
@simsolver StratSim begin
  @param environment
  @param state = nothing
  @param stack = :erosional
  @param nepochs = 10
  @param fillbase = NaN
  @param filltop = NaN
end

function preprocess(problem::SimulationProblem, solver::StratSim)
  # retrieve problem info
  pdomain = domain(problem)

  @assert embeddim(pdomain) == 3 "solver implemented for 3D domain only"

  # result of preprocessing
  preproc = Dict()

  for covars in covariables(problem, solver)
    for var in covars.names
      # get user parameters
      varparams = covars.params[(var,)]

      # determine environment
      environment = varparams.environment

      # determine initial state
      if varparams.state ≠ nothing
        state = varparams.state
      else
        nx, ny, nz = size(pdomain)
        land = zeros(nx, ny)
        state = LandState(land)
      end

      # determine stacking scheme
      stack = varparams.stack

      # determine number of epochs
      nepochs = varparams.nepochs

      # determine fill values
      fillbase = varparams.fillbase
      filltop  = varparams.filltop

      # save preprocessed input
      preproc[var] = (environment=environment, state=state,
                      stack=stack, nepochs=nepochs,
                      fillbase=fillbase, filltop=filltop)
    end
  end

  preproc
end

function solvesingle(problem::SimulationProblem, covars::NamedTuple, ::StratSim, preproc)
  # retrieve problem info
  pdomain = domain(problem)
  _, __, nz = size(pdomain)

  varreal = map(covars.names) do var
    # get parameters for the variable
    environment, state, stack, nepochs, fillbase, filltop = preproc[var]

    # simulate the environment
    record = simulate(environment, state, nepochs)

    # build stratigraphy
    strata = Strata(record, stack)

    # return voxel model
    model = voxelize(strata, nz, fillbase=fillbase, filltop=filltop)

    # flatten result
    var => vec(model)
  end

  Dict(varreal)
end
