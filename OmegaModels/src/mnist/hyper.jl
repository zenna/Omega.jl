using RunTools
using UnicodePlots
using JLD2
using TensorboardX
include("mnistflux.jl")

# Fix the saving
# Parameterize by nsteps
# Take every
# step_size
# Loss function

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

"Update Tensorboard"
function uptb(writer, name, field)
  updateaccuracy(data, stage) = nothing # Do nothing in other stages
  function updateaccuracy(data, stage::Type{Outside})
    TensorboardX.add_scalar!(writer, name, getfield(name, field), data.i)
  end
end 

testacc(data, stage) = (testacc = accuracy(net(data.ω, tX, tY)))
trainacc(data, stage) = (testacc = accuracy(net(data.ω, tX, tY)))

function infer(φ)
  X, Y = data()
  net = ciid(net_; T = Flux.Chain)
  error = loss(X, Y, net)

  # Callbacks
  writer = TensorboardX.SummaryWriter(φ[:logdir])
  tbtest = everyn(uptb(writer, "testacc", :testacc), 100)
  tbtrain = trainacc, uptb(writer, "trainacc", :trainacc)

  CbNode(idcb, (CbNode(trainacc, (tbtest, tbtrain)),))

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
  p = first(paramsamples())
  infer(p)    
end

main()
