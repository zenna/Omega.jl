using Mu
using Base.Test

## Params
## ======

φ = Params()
φ[:α] = normal(0.0, 1.0)
φ[:alg] = uniform([HMC, SSMH, MI])
const hmc_rv = iid(ω -> Dict(:nsteps => uniform(ω, 1:10),
                         :stesize => uniform(ω, 0.01, 0.1)))

alg_args(::Type{HMC}) = hmc_rv
alg_args(::Type{Any}) = iid((ω -> ()))

alg_args_(ω) = φ[:alg](ω)(ω)
φ[:alg_args] = iid(alg_args_)
φ[:nflips] = uniform(10:100)

save!(φ, "ballparams.jl")

## Run the model
## =============

nflips = 10
weight = betarv(2.0, 2.0)
flips = iid(ω -> [bernoulli(ω, weight(ω)) for i = 1:nflips])

obs = [1.0 for i = 1:nflips]
ωchain = rand(weight, flips == obs)

fname = "omegachain.bson"
save!(ω, fname)

ωchainloaded = load(fname)

# Do a few more iterations
rand(ωchainloaded[end], flips == obs)

