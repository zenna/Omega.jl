using Random
using OrdinaryDiffEq: Tsit5
using DiffEqFlux, OrdinaryDiffEq, Flux, Optim, Plots, AdvancedHMC, MCMCChains
using JLD, StatsPlots

# ----- START: OPTIMIZATION TEST FUNCTIONS ----- #
# glucose, steps, bolus, meals
function optim_all_vars_no_exo(bin_size::Int64, batch_size::Int=4, maxiters::Int=150, lr::Float64=0.01; hypo_id::Int64=1, log_dir="")
  u0, ode_data = prepare_all_data_meals_hypo(bin_size, hypo_id=hypo_id)
  _, _, _, pl = model(ode_data, batch_size, maxiters, lr, log_dir=log_dir)
  pl
end

# glucose, steps, bolus 
function optim_two_vars_no_exo(bin_size::Int64, batch_size::Int=4, maxiters::Int=150, lr::Float64=0.01)
  u0, ode_data = prepare_all_data(bin_size)
  samples, losses, best_pred = model(ode_data, batch_size, maxiters, lr)
  samples, losses, best_pred
end

# (glucose, steps) OR (glucose, bolus)
function optim_one_var_no_exo(var::String, bin_size::Int64, batch_size::Int=4, maxiters::Int=150, lr::Float64=0.01)
  u0, ode_data = prepare_data(var, bin_size)
  samples, losses, best_pred = model(ode_data, batch_size, maxiters, lr)
  samples, losses, best_predb
end

# glucose, steps, bolus, meals
function optim_all_vars_exo(bin_size::Int64, batch_size::Int=4, maxiters::Int=150, lr::Float64=0.01; hypo_id::Int64=2, log_dir="")
  @show hypo_id
  u0, ode_data = prepare_all_data_meals_hypo(bin_size, hypo_id=hypo_id)
  non_exo_data = ode_data[1:2, :]
  exo_data = ode_data[3:4, :]
  # samples, losses, best_pred = model_exo(non_exo_data, exo_data, batch_size, maxiters, lr)
  model_exo(non_exo_data, exo_data, batch_size, maxiters, lr, log_dir=log_dir)
end

# glucose, steps, bolus 
function optim_two_vars_exo(bin_size::Int64, batch_size::Int=4, maxiters::Int=150, lr::Float64=0.01)
  u0, ode_data = prepare_all_data(bin_size)
  non_exo_data = ode_data[1:2, :]
  exo_data = ode_data[3, :]
  samples, losses, best_pred = model_exo(non_exo_data, exo_data, batch_size, maxiters, lr)
end

# (glucose, steps) OR (glucose, bolus)
function optim_one_var_exo(var::String, bin_size::Int64, batch_size::Int=4, maxiters::Int=150, lr::Float64=0.01)
  u0, ode_data = prepare_data(var, bin_size)
  if var == "basis_steps"
    samples, losses, best_pred = model(ode_data, batch_size, maxiters, lr)
  else
    non_exo_data = ode_data[1, :]
    exo_data = ode_data[2, :]
    samples, losses, best_pred = model_exo(non_exo_data, exo_data, batch_size, maxiters, lr)
  end
end

# ----- END: OPTIMIZATION TEST FUNCTIONS ----- #

# ----- START: NEURAL BAYES TEST FUNCTIONS ----- #

# glucose, steps, bolus, meals
function bayes_all_vars_no_exo(bin_size::Int64;
                               numwarmup::Int = 500,
                               numsamples::Int = 500,
                               initstepsize::Float64 = 0.45,          
                               odesolver = Tsit5,
                               log_dir="")
  u0, ode_data = prepare_all_data_meals_hypo(bin_size)
  ode_data = ode_data[1:4, :]
  samples, losses, predict_neuralode = model_bayes(ode_data, numwarmup, numsamples, initstepsize, odesolver, log_dir=log_dir)
  tsteps = range(0.0, 1.0, length=size(ode_data)[2])

  ################### RETRODICTED PLOTS: TIME SERIES #################
  pl = plot(tsteps, ode_data[1,:], color = :red, label = "Data: CGM", xlabel = "t", title = "CGM, Steps, and Bolus")
  plot!(tsteps, ode_data[2,:], color = :blue, label = "Data: Steps")
  plot!(tsteps, ode_data[3,:], color = :green, label = "Data: Bolus")
  plot!(tsteps, ode_data[4,:], color = :purple, label = "Data: Meals")

  for k in 1:300
    resol = predict_neuralode(samples[400:end][rand(1:100)])
    plot!(tsteps,resol[1,:], alpha=0.1, color = :red, label = "")
    plot!(tsteps,resol[2,:], alpha=0.1, color = :blue, label = "")
    plot!(tsteps,resol[3,:], alpha=0.1, color = :green, label = "")
    plot!(tsteps,resol[4,:], alpha=0.1, color = :purple, label = "")
  end

  idx = findmin(losses)[2]
  prediction = predict_neuralode(samples[idx])

  plot!(tsteps, prediction[1,:], color = :black, w = 2, label = "C")
  plot!(tsteps, prediction[2,:], color = :black, w = 2, label = "S")
  plot!(tsteps, prediction[3,:], color = :black, w = 2, label = "B")
  plot!(tsteps, prediction[4,:], color = :black, w = 2, label = "M")
  savefig(pl, "bayes_full_data_no_exo_bin_$(bin_size)_i_$(rand(1:100)).png")
end
# glucose, steps, bolus 
function bayes_two_vars_no_exo(bin_size::Int64)
  u0, ode_data = prepare_all_data(bin_size)
  samples, losses = model_bayes(ode_data)
  samples, losses
end

# (glucose, steps) OR (glucose, bolus)
function bayes_one_var_no_exo(var::String)
  u0, ode_data = prepare_data(var, bin_size)
  samples, losses = model_bayes(ode_data)
  samples, losses
end

# glucose, steps, bolus, meals
function bayes_all_vars_exo(bin_size::Int64;
                            numwarmup::Int = 500,
                            numsamples::Int = 500,
                            initstepsize::Float64 = 0.45,          
                            odesolver = Tsit5,
                            log_dir="")
  u0, ode_data = prepare_all_data_meals_hypo(bin_size)
  non_exo_data = ode_data[1:2, :]
  exo_data = ode_data[3:4, :]
  samples, losses, predict_neuralode = model_bayes_exo(non_exo_data, exo_data, numwarmup, numsamples, initstepsize, odesolver, log_dir=log_dir)
  tsteps = range(0.0, 1.0, length=size(ode_data)[2])
  ################### RETRODICTED PLOTS: TIME SERIES #################
  pl = plot(tsteps, ode_data[1,:], color = :red, label = "Data: CGM", xlabel = "t", title = "CGM, Steps, and Bolus")
  plot!(tsteps, ode_data[2,:], color = :blue, label = "Data: Steps")
  plot!(tsteps, ode_data[3,:], color = :green, label = "Data: Bolus")
  plot!(tsteps, ode_data[4,:], color = :purple, label = "Data: Meals")

  for k in 1:300
    resol = predict_neuralode(samples[400:end][rand(1:100)])
    plot!(tsteps,resol[1,1,:], alpha=0.4, color = :red, label = "")
    plot!(tsteps,resol[2,1,:], alpha=0.4, color = :blue, label = "")
  end

  idx = findmin(losses)[2]
  prediction = predict_neuralode(samples[idx])

  plot!(tsteps, prediction[1,:], color = :black, w = 2, label = "C")
  plot!(tsteps, prediction[2,:], color = :black, w = 2, label = "S")
  savefig(pl, "bayes_full_data_exo_bin_$(bin_size)_i_$(rand(1:100)).png")
end

function bayes_all_vars_exo_with_init(bin_size::Int64;
                                      numwarmup::Int = 500,
                                      numsamples::Int = 500,
                                      initstepsize::Float64 = 0.45,          
                                      odesolver = Tsit5,
                                      log_dir="",
				                              initid=81)
  u0, ode_data = prepare_all_data_meals_hypo(bin_size)
  non_exo_data = ode_data[1:2, :]
  exo_data = ode_data[3:4, :]
  samples, losses, predict_neuralode, num = model_bayes_exo_with_init(non_exo_data, exo_data, numwarmup, numsamples, initstepsize, odesolver, log_dir=log_dir, initid=initid)
  tsteps = range(0.0, Float64(size(ode_data)[2]) - 1, length=size(ode_data)[2])
  ################### RETRODICTED PLOTS: TIME SERIES #################
  pl = plot(tsteps, ode_data[1,:], color = :red, label = "Data: CGM", xlabel = "t", title = "CGM, Steps, and Bolus")
  plot!(tsteps, ode_data[2,:], color = :blue, label = "Data: Steps")
  plot!(tsteps, ode_data[3,:], color = :green, label = "Data: Bolus")
  plot!(tsteps, ode_data[4,:], color = :purple, label = "Data: Meals")

  for k in 1:300
    resol = predict_neuralode(samples[Int(round(numsamples * 0.8)):end][rand(1:(Int(round(numsamples * 0.2)) - 1))])
    if (abs(maximum(resol[1,:])) < 30)
      plot!(tsteps,resol[1,:], alpha=0.1, color = :red, label = "")
    end
    if (abs(maximum(resol[2,:])) < 30)
      plot!(tsteps,resol[2,:], alpha=0.1, color = :red, label = "")
    end
  end

  idx = findmin(losses)[2]
  prediction = predict_neuralode(samples[idx])

  plot!(tsteps, prediction[1,:], color = :black, w = 2, label = "C")
  plot!(tsteps, prediction[2,:], color = :black, w = 2, label = "S")
  savefig(pl, joinpath(log_dir, "bayes_full_data_exo_with_init_bin_$(bin_size)_initid_$(initid)_i_$(num).png"))
end

# glucose, steps, bolus 
function bayes_two_vars_exo(bin_size::Int64)
  u0, ode_data = prepare_all_data(bin_size)
  non_exo_data = ode_data[1:2, :]
  exo_data = ode_data[3, :]
  samples, losses = model_bayes_exo(non_exo_data, exo_data)
end

# (glucose, steps) OR (glucose, bolus)
function bayes_one_var_exo(var::String)
  u0, ode_data = prepare_data(var, bin_size)
  if var == "basis_steps"
    samples, losses = model_bayes_exo(ode_data)
  else
    non_exo_data = ode_data[1, :]
    exo_data = ode_data[2, :]
    samples, losses = model_bayes_exo(non_exo_data, exo_data)
  end
end

# ----- END: NEURAL BAYES TEST FUNCTIONS ----- #
