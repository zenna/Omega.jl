# Hyper Parameter search for Spelke inference
using RunTools
using Mu
rnn_file = joinpath(Pkg.dir("Mu"), "models", "rnn", "rnn.jl")
include(rnn_file)

"Optimization-specific parameters"
function infparams()
  φ = Params()
  φ[:infalg] = HMCFAST
  φ[:infalgargs] = infparams_(φ[:infalg])
  φ
end

"Paramters for HMC algorithms"
function infparams_(::Type{HMCFAST})
  stepsize = uniform([0.0001, 0.001, 0.01, 0.1]) # FIXME!!
  nsteps = uniform([1, 2, 5, 10, 20])
  n = uniform([5000, 10000, 20000, 30000])
  Params(Dict(:stepsize => stepsize, :nsteps => nsteps, :n => n))
end

"Default is no argument params"
function infparams_(::Type{T}) where T
  Params{Symbol, Any}(Dict{Symbol, Any}(:hack => true))
end
Mu.lift(:infparams_, 1)

function runparams()
  φ = Params()
  φ[:train] = true
  φ[:loadchain] = false
  φ[:loadnet] = false

  φ[:name] = "rnn test"
  φ[:runname] = randrunname()
  φ[:tags] = ["test", "rnn"]
  φ[:logdir] = logdir(runname=φ[:runname], tags=φ[:tags])   # LOGDIR is required for sim to save
  φ[:runfile] = @__FILE__

  φ[:gitinfo] = RunTools.gitinfo()
  φ
end

"Model specific parameters"
function modelparams()
  h1 = uniform([5, 10, 15, 20, 25, 30])
  h2 = uniform([5, 10, 15, 20, 25, 30])
  Params(Dict(:h1 => h1, :h2 => h1))
end

"All parameters"
function allparams()
  φ = Params()
  φ[:modelφ] = modelparams()
  φ[:infalg] = infparams()
  φ[:α] = uniform([100.0, 200.0, 500.0, 1000.0])
#  φ[:kernel] = kernelparams()
  # φ[:runφ] = runparams()
  merge(φ, runparams()) # FIXME: replace this with line above when have magic indexing
end


"Parameters we wish to enumerate"
function enumparams()
  [Params()]
  # prod(Params(Dict(:batch_size => [12, 24, 48],
  #                  :lr => [0.0001, 0.001, 0.01])))
end

function infer(φ)
  display(φ)
  y, obvglucose, sims = withkernel(Mu.kseα(φ[:α])) do
    conditioned_model(; φ[:modelφ]...)
  end
  simsω = rand(SimpleOmega{Vector{Int}, Flux.TrackedArray}, y, 
        φ[:infalg][:infalg]; φ[:infalg][:infalgargs]...)
  p, id_ = mindistance(simsω, sims[1], obvglucose, 2)
  display((p, id_))
  path = joinpath(φ[:logdir], "rnnplotl2.pdf")
  plot_idx(id_, simsω, sims[1], obvglucose; save = true, path = path)

  path = joinpath(φ[:logdir], "rnnplotl1.pdf")
  p, id_ = mindistance(simsω, sims[1], obvglucose, 1)
  plot_idx(id_, simsω, sims[1], obvglucose; save = true, path = path)
  display((p, id_))
end

function paramsamples(nsamples = 100)
  (rand(merge(allparams(), φ, Params(Dict(:samplen => i))))  for φ in enumparams(), i = 1:nsamples)
end

function main(sim = infer, args = RunTools.stdargs())
  sim_ = args[:dryrun] ? RunTools.dry(sim) : sim
  if args[:dispatch]
    runφs = paramsamples()
    RunTools.dispatchmany(infer, runφs;
                          sbatch = args[:sbatch],
                          here = args[:here],
                          dryrun = args[:dryrun])
  elseif args[:now] 
    φ = RunTools.loadparams(args[:param])
    sim_(φ)
  end
end

main()