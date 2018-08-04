using RunTools
using UnicodePlots
using JLD2
include("mnistflux.jl")
include("../common.jl")

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
  φ[:n] = uniform([200, 500, 1000, 10000])
  φ[:stepsize] = uniform([0.1, 0.01, 0.001])
  φ[:nsteps] =  uniform([100, 200, 500, 1000])
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
  φ[:tags] = ["firsttry", "mnist"]
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

const tX, tY = testdata()
const net = ciid(net_; T = Flux.Chain)

testacc(data, stage) = nothing
testacc(data, stage::Type{Outside}) = (testacc = accuracy(net(data.ω), tX, tY),)

# trainacc(data, stage) = (testacc = accuracy(net_(data.ω, tX, tY)))

function infer(φ)
  display(φ)
  X, Y = data(φ[:modelφ][:nimages])
  @show ntotal = φ[:infalg][:infalgargs][:n] * φ[:infalg][:infalgargs][:takeevery]
  error = loss(X, Y, net)

  # Callbacks
  @show div(ntotal, 100)
  writer = TensorboardX.SummaryWriter(φ[:logdir])
  tbtest = uptb(writer, "testacc", :testacc)
  tbp = uptb(writer, "logp", :p)
  savenets = Omega.everyn(savedatajld2(joinpath(φ[:logdir], "nets"), :ω), div(ntotal, 10))

  # tbtrain = uptb(writer, "trainacc", :trainacc)
  cb = idcb → (Omega.default_cbs_tpl(φ[:infalg][:infalgargs][:n])...,
               tbp,
               savenets,
               testacc → tbtest)

  nets = infer(net, error; cb = cb, φ[:infalg][:infalgargs]...)
end

main() = RunTools.control(infer, paramsamples())

function testhyper()
  p = first(paramsamples())
  mkpath(p[:logdir])
  infer(p)
end

main()
