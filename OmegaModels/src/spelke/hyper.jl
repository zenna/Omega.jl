# Hyper Parameter search for Spelke inference
using RunTools
using Omega
using CSV
using DataFrames
using TensorboardX

function writescalar(writer, name, scalar = data -> data.p)
  function writescalra(data, ::Type{Omega.Outside})
    add_scalar!(writer, name, scalar(data), data.i)
  end
end

function writescalar(writer, name, rv::Omega.RandVar)
  function writescalra(data, ::Type{Omega.Outside})
    add_scalar!(writer, name, Omega.logepsilon(rv(data.ω)), data.i)
  end
end

include("spelke.jl")

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
  Params(Dict(:stepsize => stepsize, :nsteps => nsteps, :n => 10000))
end

"Default is no argument params"
function infparams_(::Type{T}) where T
  Params{Symbol, Any}(Dict{Symbol, Any}(:n => 10000, :hack => true))
end
Omega.lift(:infparams_, 1)

function kernelparams()
  φ = Params()
  φ[:α] = uniform([1, 10.0, 50.0, 100.0, 500.0, 1000.0])
  φ[:kernel] = Omega.kseα(φ[:α])
  # φ[:kernelargs] = kernelparams_(φ[:kernel])
  φ
end

# kernelparams_(::typeof(Omega.kf1)) = Params(:β => uniform([0.01, 0.1, 1.0, 10.0, 20.0, 40.0]))
# kernelparams_(::typeof(Omega.kse)) = Params(:α => uniform([0.01, 0.1, 1.0, 10.0, 20.0, 40.0]))
# Omega.lift(:kernelparams_, 1)

function runparams()
  φ = Params()
  φ[:train] = true
  φ[:loadchain] = false
  φ[:loadnet] = false

  φ[:name] = "spelke test"
  φ[:runname] = randrunname()
  φ[:tags] = ["rain", "spelke2"]
  φ[:logdir] = logdir(runname=φ[:runname], tags=φ[:tags])   # LOGDIR is required for sim to save
  φ[:runfile] = @__FILE__

  φ[:gitinfo] = RunTools.gitinfo()
  φ
end

function dataparams()
  Params(:datapath => joinpath(datadir(), "spelke", "data", "Balls_3_Clean", "Balls_3_Clean_DetectedObjects.csv"))
end

"All parameters"
function allparams()
  φ = Params()
  φ[:infalg] = infparams()
  φ[:kernel] = kernelparams()
  φ[:dataparams] = dataparams()
  merge(φ, runparams()) # FIXME: replace this with line above when have magic indexing
end

"Parameters we wish to enumerate"
function enumparams()
  [Params()]
end

function paramsamples(nsamples = 20)
  (rand(merge(allparams(), φ, Params(Dict(:samplen => i))))  for φ in enumparams(), i = 1:nsamples)
end

function infer(φ)
  data = CSV.read(φ[:dataparams][:datapath])
  nframes = length(unique(data[:frame]))
  frames = groupby(data, :frame)
  realvideo = map(Scene, frames)
  video = ciid(ω -> video_(ω, realvideo, nframes))
  rand(video)

  ## Tensorboard
  writer = TensorboardX.SummaryWriter(φ[:logdir])

  # Test equality at particular temperature
  pred = withkernel(φ[:kernel][:kernel]) do
    video == realvideo
  end

  predhard = withkernel(Omega.kseα(100000.0)) do
    video == realvideo
  end
  
  cb = [Omega.default_cbs(φ[:infalg][:infalgargs][:n]); writescalar(writer, "P"); writescalar(writer, "P_hard", predhard)]


  samples = rand(video, pred, φ[:infalg][:infalg]; cb = cb, φ[:infalg][:infalgargs]...);
  evalposterior(samples, realvideo, false, true)
  samples
end

main() = RunTools.control(infer, paramsamples())

main()