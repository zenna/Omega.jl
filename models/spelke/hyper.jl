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

function kernelparams()
  φ = Params()
  φ[:kernel] = uniform([Mu.kf1, Mu.kse])
  φ[:kernelargs] = kernelparams_(φ[:kernel])
  φ
end

kernelparams_(::typeof(Mu.kf1)) = Params(:β => uniform([0.01, 0.1, 1.0, 10.0, 20.0, 40.0]))
kernelparams_(::typeof(Mu.kse)) = Params(:α => uniform([0.01, 0.1, 1.0, 10.0, 20.0, 40.0]))
Mu.lift(:kernelparams_, 1)

"Paramters for HMC algorithms"
function infparams_(::Type{HMC})
  stepsize = uniform([0.0001, 0.001, 0.01, 0.1]) # FIXME!!
  nsteps = uniform([1, 2, 5, 10, 20])
  Params(Dict(:stepsize => stepsize, :nsteps => nsteps))
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

  φ[:name] = "spelke test"
  φ[:runname] = randrunname()
  φ[:tags] = ["test", "spelke"]
  φ[:logdir] = logdir(runname=φ[:runname], tags=φ[:tags])   # LOGDIR is required for sim to save
  φ[:runfile] = @__FILE__

  φ[:gitinfo] = RunTools.gitinfo()
  φ
end

"Model specific parameters"
modelparams() = Params(Dict(:temperature => 1.0))

"All parameters"
function allparams()
  φ = Params()
  φ[:modelφ] = modelparams()
  φ[:infalg] = infparams()
  φ[:kernel] = kernelparams()
  # φ[:runφ] = runparams()
  merge(φ, runparams()) # FIXME: replace this with line above when have magic indexing
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

function infer(φ)
  display(φ)
  y = simplemodel()
  rand(y, y, φ[:infalg][:infalg]; φ[:infalg][:infalgargs]...)
end

# function main(sim = infer, args = RunTools.stdargs())
#   sim_ = args[:dryrun] ? RunTools.dry(sim) : sim
#   if args[:dispatch]
#     runφs = paramsamples()
#     RunTools.dispatchmany(infer, runφs;
#                           sbatch = args[:sbatch],
#                           here = args[:here],
#                           dryrun = args[:dryrun])
#   elseif args[:now] 
#     φ = RunTools.loadparams(args[:param])
#     sim_(φ)
#   end
# end

main() = RunTools.control(infer, paramsamples())

main()