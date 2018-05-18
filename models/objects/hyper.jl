include("objects.jl")
## Params
## ======
"Optimization-specific parameters"
function infparams()
  φ = Params()
  φ[:infalg] = SSMH
  φ[:infalgargs] = infparams_(φ[:infalg])
  φ
end

"Default is no argument params"
function infparams_(::Type{T}) where T
  Params{Symbol, Any}(Dict{Symbol, Any}(:n => uniform([1000, 10000, 50000, 100000])))
end
Mu.lift(:infparams_, 1)

function runparams()
  φ = Params()
  φ[:train] = true
  φ[:loadchain] = false
  φ[:loadnet] = false

  φ[:name] = "rnn test"
  φ[:runname] = randrunname()
  φ[:tags] = ["test", "objectsgood"]
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
  scene = iid(scene_)     # Random Variable of scenes
  img = render(scene)     # Random Variable over images

  "Save images"
  function saveimg(data, stage::Type{Outside})
    imgpath = joinpath(φ[:logdir], "final$(data.i).png")
    img_ = map(Images.clamp01nan, rgbimg(img(data.ω)))
    
    FileIO.save(imgpath, rgbimg(img_))
  end

  n = φ[:infalg][:infalgargs][:n]
  pred = withkernel(Mu.kseα(φ[:α])) do
    nointersect(scene) & (img == img_obs)
  end
  samples = rand(scene, pred, φ[:infalg][:infalg];
                 cb = [Mu.default_cbs(n); Mu.throttle(saveimg, 30)],
                 φ[:infalg][:infalgargs]...)

  # Save the scenes
  path = joinpath(φ[:logdir], "omegas.bson")
  BSON.bson(path, omegas=samples)
end

main() = RunTools.control(infer, paramsamples())

main()