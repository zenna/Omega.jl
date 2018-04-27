using Mu
using Base.Test

function params_test1()
  p = Params()
  p[:x] = 5.0
end

function params_test2()
  θ = Params()
  θ[:x] = 5.0
  θ[:y] = uniform(0.0, 1.0) + θ[:x]
end

params_test2()

function model(nflips)
  nflips = φ[:x, 10]
  weight = betarv(2.0, 2.0)
  flips = iid(ω -> [bernoulli(ω, weight(ω)) for i = 1:nflips])

  obs = [1.0 for i = 1:nflips]
  rand(weight, flips == obs. φ[:alg], φ[:alg_args]...)
end

function params_test3()
  φ = Params()
  φ[:α] = normal(0.0, 1.0)
  φ[:alg] = uniform([HMC, SSMH, MI])
  hmc_rv = iid(ω -> Dict(:nsteps => uniform(ω, 1:10),
                         :stesize => uniform(ω, 0.01, 0.1)))
  alg_args(::Type{HMC}) = hmc_rv
  alg_args(::Type{<:Any}) = iid((ω -> ()))

  alg_args_(ω) = alg_args(φ[:alg](ω))(ω)
  φ[:alg_args] = iid(alg_args_)
  φ[:nflips] = uniform(10:100)
  rand(φ)
end