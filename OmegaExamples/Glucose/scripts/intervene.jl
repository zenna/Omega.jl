using DiffEqFlux, OrdinaryDiffEq, Flux, Optim, Plots, AdvancedHMC, MCMCChains
using JLD, StatsPlots
using BSON
using Random
using Glucose: prepare_all_data_meals_hypo
using NNlib
using Glucose
using LinearAlgebra
using NNlib
using Distributions
using Omega

# prepare data
_, ode_data = prepare_all_data_meals_hypo(10)

_, ode_data_unnormal = prepare_all_data_meals_hypo(10, normal = false)
glucose_mean, glucose_std = (mean(ode_data_unnormal[1, :]), std(ode_data_unnormal[1, :])) # (159.44942528735626, 54.68441830006641)
steps_mean, steps_std = (mean(ode_data_unnormal[2, :]), std(ode_data_unnormal[2, :])) # (2.1413793103448278, 2.478409230791181)
bolus_mean, bolus_std = (mean(ode_data_unnormal[3, :]), std(ode_data_unnormal[3, :])) # (0.030344827586206897, 0.12658940258683044)
meal_mean, meal_std = (mean(ode_data_unnormal[4, :]), std(ode_data_unnormal[4, :])) # (0.8620689655172413, 1.8987615875887272)

# extract optimal weights
d = BSON.load("new_model_hypo2.bson")
theta = d[:theta]

"Make time t ∈ [l, r] to index 1:n"
function scaleidx(t, lb, ub, n)
  δ = ub - lb
  Int(round(t * (n - 1) / δ + (1 - (n - 1) * lb / δ)))
end

function no_intervention(f, u, p, t, tspan, exo_data)
  datasize = size(ode_data)[2]
  scaled_t = scaleidx(t, tspan[1], tspan[2], datasize)
  f(vcat(u, exo_data[:, scaled_t]...), p)
end

"Generate the network"
function gennet()
  f = FastChain(FastDense(4, 64, swish),
    FastDense(64, 32, swish),
    FastDense(32, 2))
end

function predict_intervene(prob_intervene, θ, tsteps)
  _prob = remake(prob_intervene, p = θ)
  res = solve(_prob, Tsit5(), saveat = tsteps, abstol = 1e-9, reltol = 1e-9)
  Array(res)
end

function generate_series(f,
  u0,
  tspan,
  tsteps,
  weights::AbstractArray = theta;
  exo_data,
  intervene = (f, u, p, t) -> no_intervention(f, u, p, t, tspan, exo_data))
  # intervened model
  function f_intervene(u, p, t)
    intervene(f, u, p, t)
  end

  prob_intervene = ODEProblem(f_intervene, u0, tspan, nothing)
  Array(predict_intervene(prob_intervene, weights, tsteps))
  # Array(vcat(predict_intervene(prob_intervene, weights, tsteps), exo_data))
end

function unnormalize_data(data)
  Array(transpose(hcat(
    data[1, :] .* glucose_std .+ glucose_mean,
    data[2, :] .* steps_std .+ steps_mean,
    data[3, :] .* bolus_std .+ bolus_mean,
    data[4, :] .* meal_std .+ meal_mean
  )))
end

"""Example"""
function examplep()
  network = gennet()
  exo_data = ode_data[3:4, :]
  tspan = (0.0, 1.0)
  tsteps = range(tspan[1], tspan[2], length = 500)
  datatsteps = range(tspan[1], tspan[2], length = size(ode_data)[2])
  datasize = size(ode_data)[2]
  u0 = ode_data[1:2, 1]

  # Generate new exogenous data
  new_exo_data = deepcopy(exo_data)
  new_exo_data[2, 8] = 3.5 # 13, 3.5 
  new_exo_data[2, 9] = 3.5 # 14, 3.5
  new_exo_data[2, 10] = 3.5 # 15, 3.5
  function f_int(f, u, p, t)
    scaled_t = scaleidx(t, tspan[1], tspan[2], datasize)
    # scaled_t = Int(round(t*(datasize - 1)/(tspan[2] - tspan[1]) + (1 - (datasize - 1)*tspan[1]/(tspan[2] - tspan[1]))))
    if scaled_t in [8, 9, 10]
      f(vcat(u..., exo_data[1, scaled_t], 3.5), p) # intervening on meals!
    else
      f(vcat(u, exo_data[:, scaled_t]...), p)
    end
  end

  thetas = []
  losses1 = []
  losses2 = []

  resol1s = []
  resol2s = []
  nsamples = 100
  dist = Normal(0, 0.05)
  for i = 1:nsamples
    noise = rand(dist, length(theta))
    noisy_theta = theta .+ noise
    resol1 = generate_series(network, u0, tspan, tsteps, noisy_theta; exo_data = exo_data)
    resol2 = generate_series(network, u0, tspan, tsteps, noisy_theta; intervene = f_int, exo_data = new_exo_data)
    push!(resol1s, resol1)
    push!(resol2s, resol2)
  end
  resol1s, resol2s, new_exo_data, tsteps, exo_data, datatsteps
end

function plotexample()
  resol1s, resol2s, new_exo_data, tsteps, exo_data, datatsteps = examplep()
  nsamples = length(resol1s)
  # @show tsteps
  genplot(resol1s, resol2s, tsteps, ode_data, nsamples, exo_data, new_exo_data, datatsteps)
end

function genplot(resol1s, resol2s, tsteps, ode_data, nsamples, exo_data, new_exo_data, datatsteps)
  pl1 = plot(datatsteps, ode_data[1, :], seriestype = :scatter, color = :red, w = 1.5, label = "CGM", xlabel = "t", title = "CGM, Steps, Bolus, Meals", legend = :top)
  plot!(pl1, datatsteps, ode_data[2, :], seriestype = :scatter, color = :blue, w = 1.5, label = "Steps")
  plot!(pl1, datatsteps, ode_data[3, :], seriestype = :scatter, color = :green, w = 1.5, label = "Bolus")
  plot!(pl1, datatsteps, ode_data[4, :], color = :purple, w = 1.5, label = "Meals")

  pl2 = plot(datatsteps, ode_data[1, :], seriestype = :scatter, color = :red, w = 1.5, label = "CGM", xlabel = "t", title = "CGM, Steps, Bolus, Meals", legend = :top)
  plot!(pl2, datatsteps, ode_data[2, :], seriestype = :scatter, color = :blue, w = 1.5, label = "Steps")
  plot!(pl2, datatsteps, ode_data[3, :], seriestype = :scatter, color = :green, w = 1.5, label = "Bolus")
  plot!(pl2, datatsteps, vcat(new_exo_data[2, 1:7]..., 3.5, 3.5, 3.5, new_exo_data[2, 11:end]...), color = :purple, w = 1.5, label = "Data: Meals")

  for i = 1:nsamples
    resol1 = resol1s[i]
    resol2 = resol2s[i]
    @show size(resol1)
    @show length(tsteps)
    @show typeof(resol1)
    plot!(pl1, tsteps, resol1[1, :], alpha = 0.1, color = :red, label = "")
    plot!(pl1, tsteps, resol1[2, :], alpha = 0.1, color = :blue, label = "")

    plot!(pl2, tsteps, resol2[1, :], alpha = 0.1, color = :red, label = "")
    plot!(pl2, tsteps, resol2[2, :], alpha = 0.1, color = :blue, label = "")
  end
  pl1, pl2
end

function genmodel(ω)
  network = gennet()
  exo_data = ode_data[3:4, :]
  tspan = (0.0, 1.0)
  tsteps = range(tspan[1], tspan[2], length = 500)
  datatsteps = range(tspan[1], tspan[2], length = size(ode_data)[2])
  datasize = size(ode_data)[2]
  u0 = ode_data[1:2, 1]
  @show T = uniform(ω, 1:length(datatsteps))

  # Generate new exogenous data
  new_exo_data = copy(exo_data)
  new_exo_data[2, 8] = 3.5
  new_exo_data[2, 9] = 3.5
  new_exo_data[2, 10] = 3.5
  function f_int(f, u, p, t)
    scaled_t = scaleidx(t, tspan[1], tspan[2], datasize)
    # scaled_t = Int(round(t*(datasize - 1)/(tspan[2] - tspan[1]) + (1 - (datasize - 1)*tspan[1]/(tspan[2] - tspan[1]))))
    if scaled_t in [T - 1, T, T + 1]
      f(vcat(u..., exo_data[1, scaled_t], 3.5), p) # intervening on bolus!
    else
      f(vcat(u, exo_data[:, scaled_t]...), p)
    end
  end
  # dist = Normal(0, 0.05)
  # noise = rand(dist, length(theta))
  # noise = rand(dist, 1)
  noise = normal(ω, 0.0, 0.05)
  noisy_theta = theta .+ noise
  resol1 = generate_series(network, u0, tspan, tsteps, noisy_theta; intervene = f_int, exo_data = exo_data)
  # @show glevel(resol1) > 100.0
  Omega.cond(ω, glevel(resol1) > 100.0)
  T
end

glevel(data) = minimum(data[1, :] .* glucose_std .+ glucose_mean)
glevelrv(ω) = glevel(genmodel(ω))

gm2 = ~genmodel



function fscale(f, alpha = 4)
  Plots.scalefontsizes(alpha)
  try
    x = f()
    Plots.scalefontsizes(1 / alpha)
    x
  catch e
    Plots.scalefontsizes(1 / alpha)
    throw(e)
  end
end
