# StratiGraphics.jl

*A tool for creating 3D stratigraphy from 2D geostatistical processes.*

[![][travis-img]][travis-url] [![][julia-pkg-img]][julia-pkg-url] [![][codecov-img]][codecov-url]

![StratiGraphics Animation](docs/stratigraphics.gif)

This package provides an implementation of Markov-Poisson sampling as described
in [Hoffimann 2018](https://www.researchgate.net/publication/327426675_Morphodynamic_Analysis_and_Statistical_Synthesis_of_Geomorphic_Data).
In this method, geostatistical algorithms from the [GeoStats.jl](https://github.com/juliohm/GeoStats.jl)
framework are used to quickly generate horizons of a 3D structural model.

## Installation

Get the latest stable release with Julia's package manager:

```julia
] add StratiGraphics
```

## Usage

To illustrate the usage of the package, consider a set of satellite images containing
spatial patterns that we would like to reproduce in a 3D stratigraphic model:

![Flow Images](docs/flowimages.png)

Each image can serve as a training image for a multiple-point geostatistical algorithm
such as [ImageQuilting.jl](https://github.com/juliohm/ImageQuilting.jl):

```julia
using ImageQuilting

proc1 = ImgQuilt(:land => (TI=TI1, template=(30,30,1)))
proc2 = ImgQuilt(:land => (TI=TI2, template=(30,30,1)))
proc3 = ImgQuilt(:land => (TI=TI3, template=(30,30,1)))
```
TODO

![Voxelized Models](docs/voxelmodel.png)

[travis-img]: https://travis-ci.org/juliohm/StratiGraphics.jl.svg?branch=master
[travis-url]: https://travis-ci.org/juliohm/StratiGraphics.jl

[julia-pkg-img]: http://pkg.julialang.org/badges/StratiGraphics_0.6.svg
[julia-pkg-url]: http://pkg.julialang.org/?pkg=StratiGraphics

[codecov-img]: https://codecov.io/gh/juliohm/StratiGraphics.jl/branch/master/graph/badge.svg
[codecov-url]: https://codecov.io/gh/juliohm/StratiGraphics.jl
