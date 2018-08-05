include("objects.jl")
include("../common.jl")

function runparams()
  φ = Params()
  φ[:train] = true
  φ[:loadchain] = false
  φ[:loadnet] = false
  φ[:name] = "invgraphics"
  φ[:runname] = randrunname()
  φ[:tags] = ["test", "invgraphics"]
  φ[:logdir] = logdir(runname=φ[:runname], tags=φ[:tags])
  φ[:runfile] = @__FILE__
  φ[:gitinfo] = RunTools.gitinfo()
  φ
end

"All parameters"
function allparams()
  φ = Params()
  φ[:infalg] = infparams()
  φ[:α] = uniform([100.0, 200.0, 400.0, 500.0, 1000.0])
  φ[:n] = uniform([1000, 10000, 50000])
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
  display(φ)
  scene = ciid(scene_)                # Random Variable of scenes
  img = lift(rendersquare)(scene)     # Random Variable over images
  n = φ[:n]
  ntotal = n * 1 # φ[:infalg][:infalgargs][:takeevery]

  ## Callbacks
  writer = Tensorboard.SummaryWriter(φ[:logdir])
  # Render the observed img
  add_image!(writer, "observed", permutedims(img_obs.img, (3, 1, 2)), 1)

  # Render img at each stage of markov chian
  renderedimg(data, stage) = nothing
  renderedimg(data, stage::Type{Outside}) = (img = img(data.ω).img,)
  tbimg(data, stage) = nothing
  tbimg(data, stage::Type{Outside}) = 
    add_image!(writer, "renderedimg", permutedims(data.img, (3, 1, 2)), data.i)

  # Store the score to tensorboard
  tbp(data, stage) = nothing
  tbp(data, stage::Type{Outside}) = add_scalar!(writer, "p", data.p, data.i)

  # Save the omegas
  saveω(data, stage) = nothing
  saveω(data, stage::Type{Outside}) = savejld(data.ω, joinpath(φ[:logdir], "omega"), data.i)

  cb = idcb → (Omega.default_cbs_tpl(n)...,
               tbp,
               renderedimg → everyn(tbimg, 10),
               everyn(saveω, div(n, 10)))
  ## Sample
  samples = rand(scene, img ==ₛ img_obs, φ[:n]; cb = cb, alg = φ[:infalg][:infalg],
                                              φ[:infalg][:infalgargs]...)
end

function testhyper()
  p = first(paramsamples())
  mkpath(p[:logdir])
  infer(p)
end

main() = RunTools.control(infer, paramsamples())
main()