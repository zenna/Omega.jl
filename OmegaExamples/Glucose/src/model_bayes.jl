using DiffEqFlux, OrdinaryDiffEq, Flux, Optim, Plots, AdvancedHMC, MCMCChains
using JLD, StatsPlots
using BSON
using Random

function model_bayes(ode_data::AbstractArray, 
                     numwarmup::Int = 500,
                     numsamples::Int = 500,
                     initstepsize::Float64 = 0.45,          
                     odesolver = Tsit5;
                     log_dir="")
  u0 = ode_data[:, 1]
  println("u0")
  println(u0)
  datasize = length(ode_data[1,:])
  println("datasize")
  println(datasize)

  tspan = (0.0, 1.0) # (0.0, Float64(datasize) - 1)  # (0.0, Float64(datasize) - 1) # (0.0, 0.5*(Float64(datasize) - 1))
  tsteps = range(tspan[1], tspan[2], length = datasize) # range(tspan[1], tspan[2], length = datasize)

  data_dim = size(ode_data)[1]

  println("tspan")
  println(tspan)

  println("tsteps")
  println(tsteps)

  println("data_dim")
  println(data_dim)

  # ----- define Neural ODE architecture
  dudt2 = FastChain((x, p) -> x.^3,
      FastDense(data_dim, 25, swish), # FastDense(2, 50, tanh),
      FastDense(25, data_dim)) # FastDense(2, 50, tanh),
  prob_neuralode = NeuralODE(dudt2, tspan, odesolver(), saveat = tsteps) #Trapezoid

  # ----- define loss function for Neural ODE
  function predict_neuralode(p)
    Array(prob_neuralode(u0, p))
  end

  function loss_neuralode(p)
    pred = predict_neuralode(p)
    println("pred")
    println(size(pred))
    println("ode_data")
    println(size(ode_data))
    loss = sum(abs2, ode_data .- pred)
    return loss, pred
  end

  # ----- define Hamiltonian log density and gradient 
  l(θ) = -sum(abs2, ode_data .- predict_neuralode(θ)) - sum(θ .* θ)

  function dldθ(θ)
    x,lambda = Flux.Zygote.pullback(l, θ)
    grad = first(lambda(1))
    return x, grad
  end

  # ----- define step size adaptor function and sampler
  metric  = DiagEuclideanMetric(length(prob_neuralode.p))

  h = Hamiltonian(metric, l, dldθ)

  integrator = Leapfrog(find_good_stepsize(h, Float64.(prob_neuralode.p)))

  prop = AdvancedHMC.NUTS{MultinomialTS, GeneralisedNoUTurn}(integrator)

  adaptor = StanHMCAdaptor(MassMatrixAdaptor(metric), StepSizeAdaptor(initstepsize, prop.integrator))

  samples, stats = sample(h, prop, Float64.(prob_neuralode.p), numwarmup, adaptor, numsamples; progress=true)

  println("samples")
  println(samples)
  println(size(samples))
  println(length(samples))
  println(size(samples[1]))
  losses = map(x-> x[1],[loss_neuralode(samples[i]) for i in 1:length(samples)])
  
  if log_dir != ""
    bson(joinpath(log_dir, "bayes_model_no_exo.bson"), nn_model=prob_neuralode, samples=samples, losses=losses)
  end
  
  (samples, losses, predict_neuralode)
end

function model_bayes_exo(non_exo_data::AbstractArray, 
                         exo_data::AbstractArray,
                         numwarmup::Int = 500,
                         numsamples::Int = 500,
                         initstepsize::Float64 = 0.45,          
                         odesolver = Trapezoid;
                         log_dir="")

  #@show size(non_exo_data)
  u0 = non_exo_data[:, 1]
  datasize = length(non_exo_data[1,:])
  tspan = (0.0, Float64(datasize) - 1)  # (0.0, 1.0) # (0.0, Float64(datasize) - 1)
  tsteps = range(tspan[1], tspan[2], length = datasize) # range(tspan[1], tspan[2], length = datasize)

  input_data_dim = size(non_exo_data, 1) + size(exo_data, 1)
  output_data_dim = size(non_exo_data, 1)

  # ----- define Neural ODE architecture
  dudt = FastChain((x, p) -> x.^3,
  FastDense(input_data_dim, 50, swish), # FastDense(2, 50, tanh),
  FastDense(50, output_data_dim)) # FastDense(2, 50, tanh),
  p_model = initial_params(dudt)

  function dudt_exo(u::AbstractArray{<:Float64}, p::AbstractArray{<:Float64}, t) 
    dudt(vcat(u[:, 1], exo_data[:, t]), p)
  end

  function dudt2(u::AbstractArray{<:Float64}, p::AbstractArray{<:Float64}, t) 
    # dudt(vcat(u[:, 1], exo_data[:, t]), p)
    # println(size(u))
    # @show vcat(u, exo_data[:, Int(round(t*(datasize - 1)/(tspan[2] - tspan[1]) + (1 - (datasize - 1)*tspan[1]/(tspan[2] - tspan[1]))))])
    dudt(vcat(u, exo_data[:, Int(round(t*(datasize - 1)/(tspan[2] - tspan[1]) + (1 - (datasize - 1)*tspan[1]/(tspan[2] - tspan[1]))))]), p)
  end

  prob = ODEProblem(dudt2, u0, tspan, nothing)

  # ----- define loss function for Neural ODE
  function predict_neuralode(p)
    _prob = remake(prob, p=p)
    Array(solve(_prob, Tsit5(), saveat=tsteps, abstol = 1e-8, reltol = 1e-6))
  end

  function loss_neuralode(p)
    pred = predict_neuralode(p)
    loss = sum(abs2, non_exo_data .- pred)
    return loss, pred
  end

  # ----- define Hamiltonian log density and gradient 
  l(θ) = -sum(abs2, non_exo_data .- predict_neuralode(θ)) - sum(θ .* θ)

  function dldθ(θ)
    x, lambda = Flux.Zygote.pullback(l,θ)
    grad = first(lambda(1))
    return x, grad
  end

  # ----- define step size adaptor function and sampler
  metric = DiagEuclideanMetric(length(p_model))

  h = Hamiltonian(metric, l, dldθ)

  integrator = Leapfrog(find_good_stepsize(h, Float64.(p_model)))

  prop = AdvancedHMC.NUTS{MultinomialTS, GeneralisedNoUTurn}(integrator)

  adaptor = StanHMCAdaptor(MassMatrixAdaptor(metric), StepSizeAdaptor(initstepsize, prop.integrator))

  samples, stats = sample(h, prop, Float64.(p_model), numwarmup, adaptor, numsamples; progress=true)

  losses = map(x-> x[1],[loss_neuralode(samples[i]) for i in 1:length(samples)])

  if log_dir != ""
    bson(joinpath(log_dir, "3_bayes_model_exo$(rand).bson"), nn_model=p_model, samples=samples, losses=losses)
  end

  (samples, losses, predict_neuralode)
end

function model_bayes_exo_with_init(non_exo_data::AbstractArray, 
                                   exo_data::AbstractArray,
                                   numwarmup::Int = 500,
                                   numsamples::Int = 500,
                                   initstepsize::Float64 = 0.45,          
                                   odesolver = Trapezoid;
				                           initid=81,
                                   log_dir="")

  u0 = vcat(non_exo_data[:, 1], exo_data[:, 1])
  datasize = length(non_exo_data[1,:])
  tspan = (0.0, 1.0) # (0.0, Float64(datasize) - 1) # (0.0, 1.0)  # (0.0, 1.0) # (0.0, Float64(datasize) - 1)
  tsteps = range(tspan[1], tspan[2], length = datasize) # range(tspan[1], tspan[2], length = datasize)
   
  input_data_dim = size(non_exo_data, 1) + size(exo_data, 1)
  output_data_dim = size(non_exo_data, 1)

  # ----- define Neural ODE architecture
  # dudt = FastChain((x, p) -> x.^3,
  # FastDense(input_data_dim, 50, swish), # FastDense(2, 50, tanh),
  # FastDense(50, input_data_dim)) # FastDense(2, 50, tanh),

  # function dudt_exo(u::AbstractArray{<:Float64}, p::AbstractArray{<:Float64}) 
  #   dudt(vcat(u[:, 1], exo_data[:, 1]), p)
  # end

  # prob_neuralode = NeuralODE(dudt, tspan, odesolver(), saveat = tsteps) # Trapezoid

  d = BSON.load("/path/to/model")
  prob_neuralode = d[:nn_model]
  init_theta = d[:theta]

  # ----- define loss function for Neural ODE
  function predict_neuralode(p)
    Array(prob_neuralode(u0, p))
  end

  function loss_neuralode(p)
    pred = predict_neuralode(p)
    loss = sum(abs2, non_exo_data .- pred[1:output_data_dim,:])
    return loss, pred
  end

  # ----- define Hamiltonian log density and gradient 
  l(θ) = -sum(abs2, non_exo_data .- predict_neuralode(θ)[1:output_data_dim]) - sum(θ .* θ)

  function dldθ(θ)
    x, lambda = Flux.Zygote.pullback(l,θ)
    grad = first(lambda(1))
    return x, grad
  end

  # ----- define step size adaptor function and sampler
  metric = DiagEuclideanMetric(length(init_theta))

  h = Hamiltonian(metric, l, dldθ)

  integrator = Leapfrog(find_good_stepsize(h, Float64.(init_theta)))

  prop = AdvancedHMC.NUTS{MultinomialTS, GeneralisedNoUTurn}(integrator)

  adaptor = StanHMCAdaptor(MassMatrixAdaptor(metric), StepSizeAdaptor(initstepsize, prop.integrator))

  samples, stats = sample(h, prop, Float64.(init_theta), numwarmup, adaptor, numsamples; progress=true)

  losses = map(x-> x[1],[loss_neuralode(samples[i]) for i in 1:length(samples)])

  num = rand(1:100)
  if log_dir != ""
    bson(joinpath(log_dir, "2_bayes_model_exo$(num).bson"), nn_model=prob_neuralode, samples=samples, losses=losses, theta=init_theta)
  end

  (samples, losses, predict_neuralode, num)
end

function find_model(index::Int)
  Core.eval(Main, :(import NNlib))

  data_directory = "/path/to/model"
  folder_names = readdir(data_directory)
  println(folder_names)
  output_dictionaries = []
  for folder in folder_names
    if "model.bson" in readdir(joinpath(data_directory, folder)) # if run has finished
      d = BSON.load(joinpath(data_directory, folder, "model.bson"))
      push!(output_dictionaries, d)  
    end
  end
  sorted_dictionaries = sort(output_dictionaries, by=(x -> x[:loss]))
  sorted_dictionaries[index][:nn_model]
end

function plot_model_results(samples, losses, var::String)
  ##################### PLOTS: LOSSES ###############
  scatter(losses, ylabel = "Loss",  yscale= :log, label = "Architecture1: 500 warmup, 500 sample")

  ################### RETRODICTED PLOTS: TIME SERIES #################
  pl = scatter(tsteps, ode_data[1,:], color = :red, label = "Data: CGM", xlabel = "t", title = "CGM & $(var)")
  scatter!(tsteps, ode_data[2,:], color = :blue, label = "Data: $(var)")

  for k in 1:300
    resol = predict_neuralode(samples[100:end][rand(1:400)])
    plot!(tsteps,resol[1,:], alpha=0.1, color = :red, label = "")
    plot!(tsteps,resol[2,:], alpha=0.1, color = :blue, label = "")
  end

  idx = findmin(losses)[2]
  prediction = predict_neuralode(samples[idx])

  plot!(tsteps,prediction[1,:], color = :black, w = 2, label = "")
  plot!(tsteps,prediction[2,:], color = :black, w = 2, label = "")
  savefig(pl, "glucose_$(var)_bin_$(string(bin_size)).png")
end

function plot_model_results(samples, losses)
  ##################### PLOTS: LOSSES ###############
  scatter(losses, ylabel = "Loss",  yscale= :log, label = "Architecture1: 500 warmup, 500 sample")

  ################### RETRODICTED PLOTS: TIME SERIES #################
  pl = plot(tsteps, ode_data[1,:], color = :red, label = "Data: CGM", xlabel = "t", title = "CGM, Steps, and Bolus")
  plot!(tsteps, ode_data[2,:], color = :blue, label = "Data: Steps")
  plot!(tsteps, ode_data[3,:], color = :blue, label = "Data: Bolus")

  for k in 1:300
    resol = predict_neuralode(samples[800:end][rand(1:200)])
    plot!(tsteps,resol[1,:], alpha=0.1, color = :red, label = "")
    plot!(tsteps,resol[2,:], alpha=0.1, color = :blue, label = "")
    plot!(tsteps,resol[3,:], alpha=0.1, color = :blue, label = "")
  end

  idx = findmin(losses)[2]
  prediction = predict_neuralode(samples[idx])

  plot!(tsteps,prediction[1,:], color = :black, w = 2, label = "")
  plot!(tsteps,prediction[2,:], color = :black, w = 2, label = "")
  savefig(pl, "glucose_$(var)_bin_$(string(bin_size)).png")
end
