using Omega
using Spec
using Test
using Pkg

include("TestLib.jl")

# Add TestArrows
Pkg.develop(PackageSpec(url=joinpath(dirname(pathof(Omega)), "..", "test", "TestModels")))

walktests(Omega, exclude = ["rid.jl", "rcd.jl", "simple.jl"])

# Why not just include it?
# Put the whole thing in a module and just include it
# develo
# ∧