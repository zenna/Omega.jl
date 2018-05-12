# Hyper Parameter search for Spelke inference
using RunTools
using Mu

"Optimization-specific parameters"
function infparams()
  φ = Params()
  φ[:infalg] = uniform([HMC, MI, SSMH])
  φ[:infalgargs] = infparams_(φ[:infalg])
  φ
end

"Paramters for HMC algorithms"
function infparams_(::Type{HMC})
  stepsize = uniform([0.0001, 0.001, 0.01, 0.1]) # FIXME!!
  nsteps = uniform([1, 2, 5, 10, 20])
  Params(Dict(:stepsize => stepsize, :nsteps => nsteps))
end

"Default is no argument params"
infparams_(::Type{T}) where T = Params()
Mu.lift(:infparams_, 1)

function runparams()
  φ = Params()
  φ[:train] = true
  φ[:loadchain] = false
  φ[:loadnet] = false
  φ[:name] = "spelke test"
  φ[:runname] = randrunname()
  φ[:tags] = ["test", "spelke"]
  φ[:logdir] = logdir(runname=φ[:runname], tags=φ[:tags])
  φ[:runlocal] = false
  φ[:runsbatch] = false
  φ[:runnow] = true
  φ[:dryrun] = false
  φ[:modelparams] = modelparams()
  φ[:runfile] = @__FILE__
  φ
end

"Model specific parameters"
modelparams() = Params(Dict(:temperature => 1.0))

"All parameters"
function allparams()
  φ = Params()
  φ[:infalg] = infparams()
  merge(φ, runparams())
end

"Parameters we wish to enumerate"
function enumparams()
  [Params()]
  # prod(Params(Dict(:batch_size => [12, 24, 48],
  #                  :lr => [0.0001, 0.001, 0.01])))
end

function paramsamples(nsamples = 3)
  (rand(merge(allparams(), φ, Params(Dict(:samplen => i))))  for φ in enumparams(), i = 1:nsamples)
end

function simplemodel()
  x = normal(0.0, 1.0)
  y = normal(0.0, 1.0)
  x == y
end

using ZenUtils

function infer(φ)
  display(φ)
  y = simplemodel()
  rand(y, y, φ[:infalg][:infalg]; φ[:infalg][:infalgargs]...)
end

function main()
  runφs = paramsamples()  # Could also load this from cmdline
  dispatchmany(infer, runφs, ignoreexceptions = [Mu.InfError, Mu.NaNError])
end