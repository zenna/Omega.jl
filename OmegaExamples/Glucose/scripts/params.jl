import Glucose
using Glucose: optim_all_vars_exo
using SuParameters
using RunTools
using Omega: normal, uniform, ciid

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
  Params((binsize = uniform([10]), # 1, 5, 10
          batchsize = uniform([10]), # 6, 8, 10, 12, 15
          maxiters = uniform([300]), # [150:150:1050...]
          lr = uniform([0.01]), # 0.001, 0.005, 0.01, 0.05, 0.1
          hypoid = uniform([1,2,3]))) # 1,2,3
end

function train(params)
  samples, losses, best_pred = optim_all_vars_no_exo(params.binsize, 
                                                  params.batchsize, 
                                                  params.maxiters, 
                                                  params.lr, 
                                                  hypo_id = params.hypoid,
                                                  log_dir = params.logdir)
end

function allparams()
  φ = Params()
  merge(φ, runparams(), optparams()) # netparams()
end

"Run with julia -L params.jl -E 'hyper(;)' -- --queue"
function hyper(; params = Params(), n = 100)
  params_ = allparams()
  paramsamples = rand(params_, n)
  display.(paramsamples)
  control(train, paramsamples)
end

function testrun()
  params_ = allparams()
  train(rand(params_))
end
