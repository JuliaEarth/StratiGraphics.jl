# StratiGraphics.jl

*A tool for creating 3D stratigraphy from 2D geostatistical processes.*

[![][build-img]][build-url] [![][codecov-img]][codecov-url]

![StratiGraphics Animation](docs/stratigraphics.gif)

This package provides an implementation of Markov-Poisson sampling as described
in [Hoffimann 2018](https://searchworks.stanford.edu/view/12746435). In this method,
geostatistical algorithms from the [GeoStats.jl](https://github.com/JuliaEarth/GeoStats.jl)
framework are used to quickly generate surfaces of a 3D stratigraphic model.

## Installation

Get the latest stable release with Julia's package manager:

```julia
] add StratiGraphics
```

## Usage

To illustrate the usage of the package, consider a set of satellite images containing
spatial patterns that we would like to reproduce in a 3D stratigraphic model:

![Flow Images](docs/flowimages.png)

Each image can serve as a training image for a multiple-point geostatistical process
such as [ImageQuilting.jl](https://github.com/JuliaEarth/ImageQuilting.jl):

```julia
using ImageQuilting

proc1 = QuiltingProcess(TI1, (30,30))
proc2 = QuiltingProcess(TI2, (30,30))
proc3 = QuiltingProcess(TI3, (30,30))

procs = [proc1, proc2, proc3]
```

We define a geological environment as a set of geological processes, a set of transition
probabilities between the processes, and an event duration process:

```julia
using StratiGraphics

# transition probabilities
P = rand(3,3)
P = P ./ sum(P, dims=2)

# event duration process
ΔT = ExponentialDuration(1.0)

env = Environment(procs, P, ΔT)
```

We can simulate the environment from an initial state (e.g. flat land) and for a number of
epochs to produce a geological record:

```julia
nepochs = 10

init = LandState(zeros(100,100))

record = simulate(env, init, nepochs)
```

From the record, we can produce the strata in the form of surfaces:

```julia
strata = Strata(record)
```

We can choose between an `:erosional` (default) versus a `:depositional` stacking:

```julia
strata = Strata(record, :depositional)
```

We can then convert the surfaces into a 3D voxel model by specifying the vertical resolution:

```julia
voxelize(strata, 50) # produce a 100x100x50 voxel model
```

![Voxelized Models](docs/voxelmodel.png)

For a reproducible example, please check the [GeoStatsTutorials](https://github.com/JuliaEarth/GeoStatsTutorials).

## Citation

If you find StratiGraphics.jl useful in your work, please consider citing the thesis:

```latex
@PHDTHESIS{Hoffimann2018,
  title={Morphodynamic Analysis and Statistical Synthesis of Geomorphic Data},
  author={Hoffimann, J{\'u}lio},
  school={Stanford University},
  url={https://searchworks.stanford.edu/view/12746435},
  year={2018},
  month={September}
}
```

## Asking for help

If you have any questions, please [open an issue](https://github.com/JuliaEarth/StratiGraphics.jl/issues).

[build-img]: https://img.shields.io/github/actions/workflow/status/JuliaEarth/StratiGraphics.jl/CI.yml?branch=master&style=flat-square
[build-url]: https://github.com/JuliaEarth/StratiGraphics.jl/actions

[codecov-img]: https://img.shields.io/codecov/c/github/JuliaEarth/StratiGraphics.jl?style=flat-square
[codecov-url]: https://codecov.io/gh/JuliaEarth/StratiGraphics.jl
