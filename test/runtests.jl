using Mu
using Spec

walktests(Mu, exclude=["randcond.jl"])
walktests(Mu, joinpath("Mu", "test", "tests", "models"))

