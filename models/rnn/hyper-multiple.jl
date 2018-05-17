# Hyper Parameter search for Spelke inference
using RunTools
using Mu
using JSON
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
  stepsize = 0.01
  nsteps = 20
  n = 3000
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
  φ[:tags] = ["test", "rnn", "two_patients_many"]
  φ[:logdir] = logdir(runname=φ[:runname], tags=φ[:tags])   # LOGDIR is required for sim to save
  φ[:runfile] = @__FILE__

  φ[:gitinfo] = RunTools.gitinfo()
  φ
end

function tieparams()
  φ = Params()
  φ[:αmean] = 100
  φ[:αstd] = 100
  φ[:δmean] = .05
  φ[:δstd] = 1e-5
  merge(φ, modelparams())
end

"Model specific parameters"
function modelparams()
  h1 = 25
  h2 = 25
  Params(Dict(:h1 => h1, :h2 => h1))
end

"All parameters"
function allparams()
  φ = Params()
  φ[:modelφ] = modelparams()
  φ[:infalg] = infparams()
  φ[:αglobal] = 400
  φ[:αglobal_ind] = 600
  φ[:tiesargs] = tieparams()
#  φ[:kernel] = kernelparams()
  # φ[:runφ] = runparams()
  merge(φ, runparams()) # FIXME: replace this with line above when have magic indexing
end


"Parameters we wish to enumerate"
function enumparams(pairs = 3)
  assert(pairs <= 16)
  data = loaddata()
  ids = more_than_20(data)
  id_witness, id_treatment = ids[1:pairs], ids[pairs+1:2*pairs]
  [Params(Dict(:ids_w => [id_w], :ids_t => [id_t], 
                :observed_size => observed_size))
        for (id_w, id_t) in zip(id_witness, id_treatment) 
        for observed_size in [3, 5, 10]]
end

function infer_ties(φ)
  display(φ)
  Mu.withkernel(Mu.kseα(φ[:αglobal])) do
    y_w, y_t, ties, ties_higher, (sims_w, sims_t), 
      (glucose_w, glucose_t, glucose_t_full) =
      ties_model(;ids_w = φ[:ids_w], ids_t = φ[:ids_t],
                  observed_size = φ[:observed_size],
                 φ[:tiesargs]...)
    simsω = infer_ties(y_w, y_t, ties, ties_higher,
                      φ[:infalg][:infalg]; φ[:infalg][:infalgargs]...)
    p, id_ = mindistance(simsω, sims_w[1], glucose_w[1], 2)
    display((p, id_))
    path = joinpath(φ[:logdir], "rnnplotl_patient_w.pdf")
    plot_idx(id_, simsω, sims_w[1], glucose_w[1]; save = true, path = path)
    thinned = simsω[1000:100:end]
    selection = randperm(thinned |> length)[1:10]
    path = joinpath(φ[:logdir], "rnnsamples.pdf")
    plot_many(selection, thinned, sims_t[1], 
            [glucose_t_full[1], glucose_t[1], glucose_w[1]];
            save = true, path=path)
    path = joinpath(φ[:logdir], "simulations.json")
    save_dataset2(selection, thinned, sims_w[1], sims_t[1], 
                glucose_w[1], glucose_t[1], glucose_t_full[1];
                path = path)
    Mu.withkernel(Mu.kseα(φ[:αglobal_ind])) do
      simsω_ind = rand(SimpleOmega{Vector{Int}, Flux.TrackedArray}, y_t[1], 
                        φ[:infalg][:infalg]; φ[:infalg][:infalgargs]...)
      thinned = simsω_ind[1000:100:end]
      selection = randperm(thinned |> length)[1:10]
      path = joinpath(φ[:logdir], "simulations_no_tie.json")
      save_dataset3(selection, thinned, sims_t[1], glucose_t[1], glucose_t_full[1];
      path = path)
    end
  end
end

function paramsamples(pairs = 16)
  params = enumparams(pairs)
  (merge(allparams(), φ, Params(Dict(:samplen => i)))  for φ in params, i = 1:length(params))
end

# function paramsamples(nsamples = 400)
#   (rand(merge(allparams(), φ, Params(Dict(:samplen => i))))  for φ in enumparams(), i = 1:nsamples)
# end


main() = RunTools.control(infer_ties, paramsamples())
main()