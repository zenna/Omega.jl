using Omega
using Spec
using Test

include("TestLib.jl")

walktests(Omega, exclude = ["rid.jl", "rcd.jl", "simple.jl"])