import Glucose
using Glucose: optim_all_vars_exo
using SuParameters
using RunTools
using Omega: normal, uniform, ciid
using DiffEqFlux, OrdinaryDiffEq, Flux, Optim, Plots, AdvancedHMC, MCMCChains
using JLD, StatsPlots

function runparams()
  φ = Params()
  φ.simname = "train"
  φ.runname = ciid(randrunname)
  φ.tags = ["odeoptim", "firsttry"]
  φ.logdir = ciid(ω -> logdir(runname = φ.runname(ω), tags = φ.tags))
  φ.runfile = @__FILE__
  φ.gitinfo = current_commit(@__FILE__)
  φ
end

"Optimization Parameters"
function optparams()
  Params((binsize = uniform([10]), 
          numwarmup = uniform([500]),
          numsamples = uniform([500]),
          initstepsize = uniform([0.45]),          
          odesolver = uniform([Tsit5]) # Rosenbrock23, Trapezoid
  ))
end

function train(params)
  samples, losses = bayes_all_vars_exo(params.binsize, 
                                       params.numwarmup, 
                                       params.numsamples, 
                                       params.initstepsize,
                                       log_dir = params.logdir)
end

function allparams()
  φ = Params()
  merge(φ, runparams(), optparams()) # netparams()
end

"Run with julia -L bayesparams.jl -E 'hyper(;)' -- --queue"
function hyper(; params = Params(), n = 2)
  params_ = allparams()
  paramsamples = rand(params_, n)
  display.(paramsamples)
  control(train, paramsamples)
end

function testrun()
  params_ = allparams()
  train(rand(params_))
end