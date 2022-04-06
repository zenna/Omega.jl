### A Pluto.jl notebook ###
# v0.17.7

using Markdown
using InteractiveUtils

# ╔═╡ 9b06e82a-83d9-11ec-2bec-45900ccb18c2
begin
	import Pkg
	Pkg.activate(Base.current_project())
	Pkg.add("NNlib")
	Pkg.add("Distributions")
	# Pkg.add("DiffEq")
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
	using DiffEq
	using OrdinaryDiffEq: solve
end

# ╔═╡ dc3cc130-aa7d-417e-ac66-b3b38d4a0036
# prepare data
_, ode_data = prepare_all_data_meals_hypo(10)

# ╔═╡ 0dd8222c-a031-405e-b1fb-523b4fae908f
_, ode_data_unnormal = prepare_all_data_meals_hypo(10, normal=false)

# ╔═╡ 28566c39-a010-4f61-864d-4f052b1cb784
glucose_mean, glucose_std = (mean(ode_data_unnormal[1, :]), std(ode_data_unnormal[1, :])) # (159.44942528735626, 54.68441830006641)

# ╔═╡ ab98112d-6ddc-4b51-aaed-c46711b745e1
steps_mean, steps_std = (mean(ode_data_unnormal[2, :]), std(ode_data_unnormal[2, :])) # (2.1413793103448278, 2.478409230791181)

# ╔═╡ 746fdb88-587f-417b-bbf9-6dca06110730
bolus_mean, bolus_std = (mean(ode_data_unnormal[3, :]), std(ode_data_unnormal[3, :])) # (0.030344827586206897, 0.12658940258683044)

# ╔═╡ 2cb2b71b-e327-49a4-852c-84768a379326
meal_mean, meal_std = (mean(ode_data_unnormal[4, :]), std(ode_data_unnormal[4, :])) # (0.8620689655172413, 1.8987615875887272)

# ╔═╡ 95ff457e-a43e-4429-8289-7a86fbe44b72
begin
	if isfile("new_model_hypo2.bson")
		d = BSON.load("new_model_hypo2.bson")
		theta = d[:thetas]
	else
		theta, losses, prob = optim_all_vars_exo(10, log_dir="")
	end
end
# FIXME: Generate data if not there: extract optimal weights
# d = BSON.load("new_model_hypo2.bson")

# ╔═╡ 87467485-7e2f-454b-95f6-89996703890d
"Make time t ∈ [l, r] to index 1:n"
function scaleidx(t, lb, ub, n)
  δ = ub - lb
  Int(round(t*(n - 1)/δ + (1 - (n - 1)*lb/δ)))
end

# ╔═╡ 6582679c-f481-4359-bb31-89eb23cd361b
function no_intervention(f, u, p, t, tspan, exo_data)
  datasize = size(ode_data)[2]
  scaled_t = scaleidx(t, tspan[1], tspan[2], datasize)
  f(vcat(u, exo_data[:, scaled_t]...), p)
end

# ╔═╡ 4ebd0515-b8c5-4069-83bd-a8bd17a4b90f
"Generate the network"
function gennet()
  f = FastChain(FastDense(4, 64, swish),
                FastDense(64, 32, swish),
                FastDense(32, 2))
end

# ╔═╡ 99397fa7-0cf3-447a-b03e-711514b5a505
function predict_intervene(prob_intervene, θ, tsteps)
  _prob = remake(prob_intervene, p=θ)
  res = solve(_prob, Tsit5(), saveat=tsteps, abstol = 1e-9, reltol = 1e-9)
  Array(res)
end

# ╔═╡ 5bfbf974-b7b5-4aac-ae8c-3c2b5d61eb81
function generate_series(f,
                         u0,
                         tspan,
                         tsteps,
                         weights::AbstractArray=theta;
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

# ╔═╡ 6bc373f4-1964-4191-a283-735277652912
function unnormalize_data(data)
  Array(transpose(hcat(
    data[1,:] .* glucose_std .+ glucose_mean,
    data[2, :] .* steps_std .+ steps_mean,
    data[3, :] .* bolus_std .+ bolus_mean,
    data[4, :] .* meal_std .+ meal_mean
  )))
end

# ╔═╡ 5ef4dd73-79a3-49c3-95b0-936865aaff58


# ╔═╡ 615ca691-a2c1-423b-8199-f66b1d07cd19


# ╔═╡ ec7bdeff-b05d-4092-ac3e-bc334c1b5d4d
I = constant(no_intervention)

# ╔═╡ 8fbaec56-660d-4148-bd89-1b81f0f382a3
Data(ω) = exo_data = ode_data[3:4, :]

# ╔═╡ 79d0e2cc-fea3-42b6-b8bd-e4b36fee2bd9
"""Example"""
function examplep(ω)
  network = gennet()
  exo_data = ode_data[3:4, :]
  tspan = (0.0, 1.0)
  tsteps =  range(tspan[1], tspan[2], length = 500)
  datatsteps = range(tspan[1], tspan[2], length=size(ode_data)[2])
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
  dist = (@~ Normal(0, 0.05))(ω)
	
  for i = 1:nsamples
    noise = rand(dist, length(theta))
    noisy_theta = theta .+ noise
    resol1 = generate_series(network, u0, tspan, tsteps, noisy_theta; exo_data = exo_data)
    resol2 = generate_series(network, u0, tspan, tsteps, noisy_theta; intervene =  f_int, exo_data = new_exo_data)
    push!(resol1s, resol1)
    push!(resol2s, resol2)
  end
  resol1s, resol2s, new_exo_data, tsteps, exo_data, datatsteps
end

# ╔═╡ 43e1fed4-ad83-4d6a-ba37-ed9ff68eceeb
function genplot(resol1s, resol2s, tsteps, ode_data, nsamples, exo_data, new_exo_data, datatsteps)
  pl1 = plot(datatsteps, ode_data[1,:], seriestype = :scatter, color = :red, w=1.5, label = "CGM", xlabel = "t", title = "CGM, Steps, Bolus, Meals", legend = :top)
  plot!(pl1, datatsteps, ode_data[2,:], seriestype = :scatter, color = :blue, w=1.5, label = "Steps")
  plot!(pl1, datatsteps, ode_data[3,:], seriestype = :scatter, color = :green, w=1.5, label = "Bolus")
  plot!(pl1, datatsteps, ode_data[4,:], color = :purple, w=1.5, label = "Meals")

  pl2 = plot(datatsteps, ode_data[1,:], seriestype = :scatter, color = :red, w=1.5, label = "CGM", xlabel = "t", title = "CGM, Steps, Bolus, Meals", legend = :top)
  plot!(pl2, datatsteps, ode_data[2,:], seriestype = :scatter, color = :blue, w=1.5, label = "Steps")
  plot!(pl2, datatsteps, ode_data[3,:], seriestype = :scatter, color = :green, w=1.5, label = "Bolus")
  plot!(pl2, datatsteps, vcat(new_exo_data[2,1:7]..., 3.5, 3.5, 3.5, new_exo_data[2, 11:end]...), color = :purple, w=1.5, label = "Data: Meals")

  for i = 1:nsamples
    resol1 = resol1s[i]
    resol2 = resol2s[i]
    @show size(resol1)
    @show length(tsteps)
    @show typeof(resol1)
    plot!(pl1, tsteps,resol1[1,:], alpha=0.1, color = :red, label = "")
    plot!(pl1, tsteps,resol1[2,:], alpha=0.1, color = :blue, label = "")

    plot!(pl2, tsteps,resol2[1,:], alpha=0.1, color = :red, label = "")
    plot!(pl2, tsteps,resol2[2,:], alpha=0.1, color = :blue, label = "")
  end
  pl1, pl2    
end

# ╔═╡ 850713d5-9103-4066-8168-dcb5851c259c
function plotexample()
  resol1s, resol2s, new_exo_data, tsteps, exo_data, datatsteps = examplep()
  nsamples = length(resol1s)
  # @show tsteps
  genplot(resol1s, resol2s, tsteps, ode_data, nsamples, exo_data, new_exo_data, datatsteps)
end

# ╔═╡ 50203b94-754c-430b-b999-a2606c135a48
p1, p2 = plotexample();

# ╔═╡ 0639a05b-222c-4926-9db2-db32fcd85e67
p1

# ╔═╡ 313b31cd-76a4-445f-8bb4-dd6d040546cc
p2

# ╔═╡ 9ff58d29-9eb3-4f57-bd97-0a6be1816f4c
network = gennet()

# ╔═╡ e8291111-4d8f-4484-a468-09d91b4fac79
function examplex(ω)
  exo_data = Data(ω)
  tspan = (0.0, 1.0)
  tsteps =  range(tspan[1], tspan[2], length = 500)
  datatsteps = range(tspan[1], tspan[2], length=size(ode_data)[2])
  datasize = size(ode_data)[2]
  u0 = ode_data[1:2, 1]

  function f_int(f, u, p, t)
    scaled_t = scaleidx(t, tspan[1], tspan[2], datasize)
    if scaled_t in [8, 9, 10]
        f(vcat(u..., exo_data[1, scaled_t], 3.5), p) # intervening on meals!
    else
        f(vcat(u, exo_data[:, scaled_t]...), p)
    end
  end

  intervention = I(ω)

  nsamples = 100
  noise = (@~ Normal(0, 0.05))(ω)
  noisy_theta = theta .+ noise
  generate_series(network, u0, tspan, tsteps, noisy_theta;
	  			  exo_data = exo_data, intervention = intervention)
end

# ╔═╡ 4ca22489-90b4-47cc-bb1b-4c66a2a221a4
randsample(examplex)

# ╔═╡ b453e716-c5c8-4bca-9131-26d8df68eb8f
exo_data = ode_data[3:4, :]

# ╔═╡ ba89f0ad-1fc3-48c3-b578-44472e2ae78b
function DataAddMeals(ω)
	new_exo_data = deepcopy(exo_data)
	new_exo_data[2, 8] = 3.5 # 13, 3.5 
  	new_exo_data[2, 9] = 3.5 # 14, 3.5
  	new_exo_data[2, 10] = 3.5 # 15, 3.5
	new_exo_data
end

# ╔═╡ 4ecdc9aa-7c0b-4312-818d-134b2ed52a41
examples |ᵈ (Data => DataAddMeals)

# ╔═╡ 281efedb-aaea-4e48-8840-3b5b588dcae3
tspan = (0.0, 1.0)

# ╔═╡ 35560947-58f2-4a51-b926-22a74fdab58a
tsteps =  range(tspan[1], tspan[2], length = 500)

# ╔═╡ 9b128cdd-5e94-4639-a097-91d0f98e131d
datatsteps = range(tspan[1], tspan[2], length=size(ode_data)[2])

# ╔═╡ 6be8b340-781b-42ee-8e80-c78da347c5dc
datasize = size(ode_data)[2]

# ╔═╡ 39eb16c8-a93d-442c-8dc9-1982cd0ae79f
u0 = ode_data[1:2, 1]

# ╔═╡ 8a47a4d9-dac3-472c-9f7f-776e47bdb1a9
T = @~ DiscreteUniform(1, length(datatsteps))

# ╔═╡ 89c0ca23-5446-4093-89a7-a16e02c8cf55
randsample(T)

# ╔═╡ 8171ca8d-16f7-423c-be29-07b82d64dca9
glevel(data) = minimum(data[1,:] .* glucose_std .+ glucose_mean)

# ╔═╡ 141ad1e5-3abb-4db8-9d5d-9341839a28d4
function genmodel(ω)
  t_ = T(ω)

  # Generate new exogenous data
  new_exo_data = copy(exo_data)
  new_exo_data[2, 8] = 3.5
  new_exo_data[2, 9] = 3.5
  new_exo_data[2, 10] = 3.5
	
  function f_int(f, u, p, t)
    scaled_t = scaleidx(t, tspan[1], tspan[2], datasize)
      # scaled_t = Int(round(t*(datasize - 1)/(tspan[2] - tspan[1]) + (1 - (datasize - 1)*tspan[1]/(tspan[2] - tspan[1]))))
    if scaled_t in [t_-1, t_, t_+1]
        f(vcat(u..., exo_data[1, scaled_t], 3.5), p) # intervening on bolus!
    else
        f(vcat(u, exo_data[:, scaled_t]...), p)
    end
  end
	
  # dist = Normal(0, 0.05)
  # noise = rand(dist, length(theta))
  # noise = rand(dist, 1)
  noise = (@~ Normal(0.0, 0.05))(ω)
  noisy_theta = theta .+ noise
  resol1 = generate_series(network, u0, tspan, tsteps, noisy_theta; intervene = f_int, exo_data = exo_data)
  # @show glevel(resol1) > 100.0
  Omega.cond!(ω, glevel(resol1) > 100.0)
  t_
end

# ╔═╡ 6b01d502-73e2-4df7-9065-c35b1f5d9f2d
samplse = randsample(genmodel, 1000)

# ╔═╡ 2a20b0da-65d1-4d03-868e-e410e74effd4
histogram(samplse)

# ╔═╡ 2467b923-fbcf-4495-a002-3e2db55299c9
glevelrv(ω) = glevel(genmodel(ω))

# ╔═╡ 2b3dc1a7-5ea2-43df-8a64-c36fa2b52bed
gm2 = ~genmodel

# ╔═╡ 22fb08da-474a-4614-9e89-f45660ba60d2
function fscale(f, alpha = 4)
  Plots.scalefontsizes(alpha)
  try
    x = f()
    Plots.scalefontsizes(1/alpha)
    x
  catch e
    Plots.scalefontsizes(1/alpha)
    throw(e)
  end
end

# ╔═╡ Cell order:
# ╠═9b06e82a-83d9-11ec-2bec-45900ccb18c2
# ╠═dc3cc130-aa7d-417e-ac66-b3b38d4a0036
# ╠═0dd8222c-a031-405e-b1fb-523b4fae908f
# ╠═28566c39-a010-4f61-864d-4f052b1cb784
# ╠═ab98112d-6ddc-4b51-aaed-c46711b745e1
# ╠═746fdb88-587f-417b-bbf9-6dca06110730
# ╠═2cb2b71b-e327-49a4-852c-84768a379326
# ╠═95ff457e-a43e-4429-8289-7a86fbe44b72
# ╠═87467485-7e2f-454b-95f6-89996703890d
# ╠═6582679c-f481-4359-bb31-89eb23cd361b
# ╠═4ebd0515-b8c5-4069-83bd-a8bd17a4b90f
# ╠═99397fa7-0cf3-447a-b03e-711514b5a505
# ╠═5bfbf974-b7b5-4aac-ae8c-3c2b5d61eb81
# ╠═6bc373f4-1964-4191-a283-735277652912
# ╠═5ef4dd73-79a3-49c3-95b0-936865aaff58
# ╠═615ca691-a2c1-423b-8199-f66b1d07cd19
# ╠═ec7bdeff-b05d-4092-ac3e-bc334c1b5d4d
# ╠═8fbaec56-660d-4148-bd89-1b81f0f382a3
# ╠═ba89f0ad-1fc3-48c3-b578-44472e2ae78b
# ╠═e8291111-4d8f-4484-a468-09d91b4fac79
# ╠═4ecdc9aa-7c0b-4312-818d-134b2ed52a41
# ╠═4ca22489-90b4-47cc-bb1b-4c66a2a221a4
# ╠═79d0e2cc-fea3-42b6-b8bd-e4b36fee2bd9
# ╠═850713d5-9103-4066-8168-dcb5851c259c
# ╠═50203b94-754c-430b-b999-a2606c135a48
# ╠═0639a05b-222c-4926-9db2-db32fcd85e67
# ╠═313b31cd-76a4-445f-8bb4-dd6d040546cc
# ╠═43e1fed4-ad83-4d6a-ba37-ed9ff68eceeb
# ╠═9ff58d29-9eb3-4f57-bd97-0a6be1816f4c
# ╠═b453e716-c5c8-4bca-9131-26d8df68eb8f
# ╠═281efedb-aaea-4e48-8840-3b5b588dcae3
# ╠═35560947-58f2-4a51-b926-22a74fdab58a
# ╠═9b128cdd-5e94-4639-a097-91d0f98e131d
# ╠═6be8b340-781b-42ee-8e80-c78da347c5dc
# ╠═39eb16c8-a93d-442c-8dc9-1982cd0ae79f
# ╠═8a47a4d9-dac3-472c-9f7f-776e47bdb1a9
# ╠═141ad1e5-3abb-4db8-9d5d-9341839a28d4
# ╠═89c0ca23-5446-4093-89a7-a16e02c8cf55
# ╠═6b01d502-73e2-4df7-9065-c35b1f5d9f2d
# ╠═2a20b0da-65d1-4d03-868e-e410e74effd4
# ╠═8171ca8d-16f7-423c-be29-07b82d64dca9
# ╠═2467b923-fbcf-4495-a002-3e2db55299c9
# ╠═2b3dc1a7-5ea2-43df-8a64-c36fa2b52bed
# ╠═22fb08da-474a-4614-9e89-f45660ba60d2
