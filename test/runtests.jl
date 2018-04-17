using Mu
using Spec

walktests(Mu, test_dir = joinpath(Pkg.dir("Mu"), "test", "models"))
walktests(Mu, test_dir = joinpath(Pkg.dir("Mu"), "test", "inference"))
walktests(Mu, exclude=["randcond.jl"])