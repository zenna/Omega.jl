using Omega
using Spec
using Test
using Pkg

# FIXME: Make this a package
include("TestLib.jl")

# Add TestModels as submodule
Pkg.develop(PackageSpec(url=joinpath(dirname(pathof(Omega)), "..", "test", "OmegaTestModels")))

walktests(Omega, exclude = ["typestable.jl", "simple.jl"])