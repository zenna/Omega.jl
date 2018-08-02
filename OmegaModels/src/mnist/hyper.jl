using RunTools
using UnicodePlots
using JLD2
include("mnistflux.jl")

# Take every
# Loss function

## Params
## ======
"Inference-specific parameters"
function infparams()
  φ = Params()
  φ[:infalg] = HMCFAST
  φ[:infalgargs] = infparams_(φ[:infalg])
  φ
end

"HMCFAST Specific Params"
function infparams_(::Omega.HMCFASTAlg)
  φ = Params()
  φ[:n] = uniform([100, 200, 1000, 10000])
  φ[:stepsize] = uniform([0.1, 0.01, 0.001, 0.0001])
  φ[:nsteps] =  uniform([1, 5, 10, 50, 100])
  φ[:takeevery] =  uniform([10])
  φ
end
Omega.lift(:infparams_, 1)

function runparams()
  φ = Params()
  φ[:train] = true
  φ[:loadchain] = false
  φ[:loadnet] = false

  φ[:name] = "mnist"
  φ[:runname] = randrunname()
  φ[:tags] = ["test", "mnist"]
  φ[:logdir] = logdir(runname=φ[:runname], tags=φ[:tags])   # LOGDIR is required for sim to save
  φ[:runfile] = @__FILE__

  φ[:gitinfo] = RunTools.gitinfo()
  φ
end

function modelparams()
  φ = Params()
  φ[:nimages] = uniform([200, 1000, 10000, 30000])
  φ
end

"All parameters"
function allparams()
  φ = Params()
  φ[:modelφ] = modelparams()
  φ[:infalg] = infparams()
  φ[:α] = uniform([100.0, 200.0, 400.0, 500.0, 1000.0])
  merge(φ, runparams())
end

function paramsamples(nsamples = 10)
  (rand(merge(allparams(), φ, Params(Dict(:samplen => i))))  for φ in enumparams(), i = 1:nsamples)
end

"Parameters we wish to enumerate"
function enumparams()
  [Params()]
end

function infer(φ)
  X, Y = data(φ[:modelφ][:nimages])
  net = ciid(net_; T = Flux.Chain)
  error = loss(X, Y, net)
  nets = infer(net, error; φ[:infalg][:infalgargs]...)

  # Save the scenes
  tX, tY = testdata()
  accs = [accuracy(net, tX, tY) for net in nets]
  @show mean(accs)
  @show accs[end]
  
  # Show accuracy
  println(UnicodePlots.lineplot(accs))
  
  path = joinpath(φ[:logdir], "nets.jld2")
  @save path nets
end

main() = RunTools.control(infer, paramsamples())

function testhyper()
  infer(first(paramsamples()))    
end

main()
