using RunTools
using UnicodePlots
include("mnistflux.jl")

## Params
## ======
"Optimization-specific parameters"
function infparams()
  φ = Params()
  φ[:infalg] = HMCFAST
  φ[:infalgargs] = infparams_(φ[:infalg])
  φ
end

"Default is no argument params"
function infparams_(::Any)
  Params{Symbol, Any}(Dict{Symbol, Any}(:n => uniform([100, 200])))
end
Omega.lift(:infparams_, 1)

function runparams()
  φ = Params()
  φ[:train] = true
  φ[:loadchain] = false
  φ[:loadnet] = false

  φ[:name] = "mnist test"
  φ[:runname] = randrunname()
  φ[:tags] = ["test", "mnist"]
  φ[:logdir] = logdir(runname=φ[:runname], tags=φ[:tags])   # LOGDIR is required for sim to save
  φ[:runfile] = @__FILE__

  φ[:gitinfo] = RunTools.gitinfo()
  φ
end

"All parameters"
function allparams()
  φ = Params()
  # φ[:modelφ] = modelparams()
  φ[:infalg] = infparams()
  φ[:α] = uniform([100.0, 200.0, 400.0, 500.0, 1000.0])
#  φ[:kernel] = kernelparams()
  # φ[:runφ] = runparams()
  merge(φ, runparams()) # FIXME: replace this with line above when have magic indexing
end

function paramsamples(nsamples = 10)
  (rand(merge(allparams(), φ, Params(Dict(:samplen => i))))  for φ in enumparams(), i = 1:nsamples)
end

"Parameters we wish to enumerate"
function enumparams()
  [Params()]
end

function infer(φ)
  X, Y = data()
  net = ciid(net_; T = Flux.Chain)
  error = loss(X, Y, net)
  nets = infer(net, error; φ[:infalg][:infalgargs]...)

  # Save the scenes
  
  accs = [accuracy(net, tX, tY) for net in nets]
  @show mean(accs)
  @show accs[end]
  
  # Show accuracy
  println(UnicodePlots.lineplot(accs))
  
  path = joinpath(φ[:logdir], "nets.bson")
  BSON.bson(path, nets=nets)
end

main() = RunTools.control(infer, paramsamples())

function testhyper()
  infer(first(paramsamples()))    
end

main()
