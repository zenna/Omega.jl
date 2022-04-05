using OrdinaryDiffEq, Flux, Random
using DiffEqFlux
using BSON: @save, bson

function model(ode_data::AbstractArray, batch_size::Int=4, maxiters::Int=150, lr::Float64=0.01; log_dir="")
  # u0, ode_data = prepare_data("basis_steps", bin_size)
  u0 = ode_data[:, 1]
  data_dim = length(u0)
  datasize = length(ode_data[1,:])
  tspan = (0.0, Float64(datasize) - 1)
  tsteps = range(tspan[1], tspan[2], length = datasize)
  
  train_t = tsteps
  train_y = ode_data
  
  function neural_ode(t, data_dim; saveat = t)
      # println(data_dim)
      f = FastChain(FastDense(data_dim, 64, swish),
                    FastDense(64, 32, swish),
                    FastDense(32, data_dim))
  
      node = NeuralODE(f, (minimum(t), maximum(t)), Tsit5(),
                       saveat = saveat, abstol = 1e-9,
                       reltol = 1e-9)
  end
  
  function train_one_round(node, θ, y, opt, maxiters,
                           y0 = y[:, 1]; kwargs...)
  
      predict(θ) = Array(node(y0, θ))
      loss(θ) = begin
          pred = predict(θ)
          Flux.mse(pred, y)
      end
  
      θ = θ == nothing ? node.p : θ
      res = DiffEqFlux.sciml_train(
          loss, θ, opt,
          maxiters = maxiters;
          kwargs...
      )
      return res.minimizer
  end
  
  function train(θ = nothing, maxiters = maxiters, lr = lr)
      log_results(θs, losses) =
          (θ, loss) -> begin
              push!(θs, copy(θ))
              push!(losses, loss)
              false
          end
  
      θs, losses = [], []
      num_obs = batch_size:batch_size:length(train_t)
      for k in num_obs
        println(k)
        node = neural_ode(train_t[1:k], data_dim)
	println(log_dir)
        if log_dir != ""
          bson(joinpath(log_dir, "model$(k).bson"), nn_model=node, thetas=θs)
        end
        θ = train_one_round(
            node, θ, train_y[:, 1:k],
            ADAMW(lr), maxiters;
            cb = log_results(θs, losses)
        )
      end
      # last iteration
      node = neural_ode(train_t, data_dim)
      θ = train_one_round(
            node, θ, train_y,
            ADAMW(lr), maxiters, train_y[:, 1];
            cb = log_results(θs, losses)
      )
      θs, losses, node
  end
  
  # Random.seed!(1)
  θs, losses, node = train();
  # node = neural_ode(train_t, input_data_dim, output_data_dim)
  idx = findmin(losses)[2]
  θ = θs[idx]
  y0 = train_y[:, 1]
  resol = Array(node(y0, θ))
  
  # v = "Steps"
  pl = plot(tsteps, ode_data[1,:], color = :red, label = "Data: CGM", xlabel = "t", title = "CGM, Steps, Bolus, Meals")
  plot!(tsteps, ode_data[2,:], color = :blue, label = "Data: Steps")
  plot!(tsteps, ode_data[3,:], color = :green, label = "Data: Bolus")
  plot!(tsteps, ode_data[4,:], color = :purple, label = "Data: Meals")
  plot!(tsteps,resol[1,:], alpha=0.5, color = :red, label = "CGM")
  plot!(tsteps,resol[2,:], alpha=0.5, color = :blue, label = "Steps")
  plot!(tsteps,resol[3,:], alpha=0.5, color = :red, label = "Bolus")
  plot!(tsteps,resol[4,:], alpha=0.5, color = :blue, label = "Meals")

  println(log_dir)
  println("idx")
  println(idx)
  println("theta")
  println(θ)
  println("y0")
  println(y0)
  println("resol")
  println(resol)
  if log_dir != ""
    println(joinpath(log_dir, "model.bson"))
    bson(joinpath(log_dir, "4_model.bson"), nn_model=node, theta=θ, loss=losses[idx], best_pred=resol, y0=y0)
  end

  θ, losses[idx], resol, pl

end

function model_exo(non_exo_data::AbstractArray, exo_data::AbstractArray, batch_size::Int64=4, maxiters::Int=150, lr=0.01; log_dir="")
  # u0, ode_data = prepare_data("basis_steps", bin_size)
  u0 = non_exo_data[:, 1]
  datasize = length(non_exo_data[1,:])
  tspan = (0.0, 1.0) # (0.0, Float64(datasize) - 1)
  tsteps = range(tspan[1], tspan[2], length = datasize)

  @show maxiters

  input_data_dim = size(non_exo_data, 1) + size(exo_data, 1)
  output_data_dim = size(non_exo_data, 1)
  
  println("input_data_dim")
  println(input_data_dim)
  
  println("output_data_dim")
  println(output_data_dim)

  train_t = tsteps
  train_y = non_exo_data
  println("datasize")
  println(datasize)
  println("train_y")
  println(size(train_y))
  println(train_y)
  println("train_t")
  println(train_t)
  
  function neural_ode(t, input_data_dim, output_data_dim; saveat = t)
      # println(data_dim)
      f = FastChain(FastDense(input_data_dim, 64, swish),
                    FastDense(64, 32, swish),
                    FastDense(32, output_data_dim))
      p_model = initial_params(f)
      function f_exo(u, p, t)
        f(vcat(u, exo_data[:, Int(round(t*(datasize - 1)/(tspan[2] - tspan[1]) + (1 - (datasize - 1)*tspan[1]/(tspan[2] - tspan[1]))))]), p)
      end
      prob = ODEProblem(f_exo, u0, tspan, nothing)
      prob, p_model
  end
  
  function train_one_round(prob, p_model, θ, y, opt, maxiters,
                            y0 = y[:, 1]; kwargs...)

      # println("SHOW HERE 2")
      # @show size(y)
      function predict(θ)
        _prob = remake(prob, p=θ)
        Array(solve(_prob, Tsit5(), saveat=tsteps, abstol = 1e-9, reltol = 1e-9))
      end
      # predict(θ) = Array(node(y0, θ))
      function loss(θ)
        pred = predict(θ)
        # println("SHOW HERE 3")
        # @show size(pred)
        Flux.mse(pred[:, 1:size(y)[2]], y)
      end
      
      @show maxiters
      θ = θ == nothing ? p_model : θ
      res = DiffEqFlux.sciml_train(
          loss, θ, opt, 
          maxiters=maxiters;
          kwargs...
      )
      return res.minimizer
  end
  
  function train(θ = nothing, maxiters = maxiters, lr = lr)
      log_results(θs, losses) =
          (θ, loss) -> begin
              push!(θs, copy(θ))
              push!(losses, loss)
              false
          end
  
      θs, losses = [], []
      num_obs = batch_size:batch_size:length(train_t)
      for k in num_obs
        println(k)
        prob, p_model = neural_ode(train_t[1:k], input_data_dim, output_data_dim)
        # println("LOOK HERE")
        # @show size(train_y[:, 1:k])
        if log_dir != ""
          bson(joinpath(log_dir, "model$(k).bson"), nn_model=prob, thetas=θs)
        end
        @show train_y[:, 1:k]
        θ = train_one_round(
            prob, p_model, θ, train_y[:, 1:k],
            ADAMW(lr), maxiters, train_y[:, 1];
            cb = log_results(θs, losses)
        )
        @show length(losses)
      end
      # last iteration
      prob, p_model = neural_ode(train_t, input_data_dim, output_data_dim)
      θ = train_one_round(
            prob, p_model, θ, train_y,
            ADAMW(lr), maxiters, train_y[:, 1];
            cb = log_results(θs, losses)
      )
      @show length(losses)
      θs, losses, prob
  end
  
  # Random.seed!(1)
  θs, losses, prob = train();
  # node = neural_ode(train_t, input_data_dim, output_data_dim)  
  # idx = findmin(losses)[2]
  # @show length(losses)
  # @show idx

  @show length(losses)
  @show findmin(losses)

  @show findmin(losses[(end - maxiters):end])
  idx = findmin(losses[(end - maxiters):end])[2] + length(losses) - maxiters - 1
  θ = θs[idx]
  y0 = train_y[:, 1]
  _prob = remake(prob, p=θ)
  resol = Array(solve(_prob, Tsit5(), saveat=tsteps, abstol = 1e-9, reltol = 1e-9))

  println(log_dir)
  println("idx")
  println(idx)
  println("theta")
  println(θ)
  println("y0")
  println(y0)
  println("resol")
  println(resol)

  pl = plot(tsteps, non_exo_data[1,:], color = :red, label = "Data: CGM", xlabel = "t", title = "CGM, Steps, Bolus, Meals")
  plot!(tsteps, non_exo_data[2,:], color = :blue, label = "Data: Steps")
  plot!(tsteps, exo_data[1,:], color = :green, label = "Data: Bolus")
  plot!(tsteps, exo_data[2,:], color = :purple, label = "Data: Meals")
  plot!(tsteps,resol[1,:], alpha=0.5, color = :red, label = "CGM")
  plot!(tsteps,resol[2,:], alpha=0.5, color = :blue, label = "Steps")
  pl

  num = string(now()) # rand(1:100) 
  println(log_dir)
  if log_dir != ""
    println(joinpath(log_dir, "1_model$(num).bson"))
    bson(joinpath(log_dir, "1_model$(num).bson"), nn_model=prob, theta=θ, loss=losses[idx], best_pred=resol, y0=y0)
    savefig(pl, joinpath(log_dir, "1_image$(num).png"))
  end
  
  θ, losses[idx], resol
end



# for bin_size in [20, 15, 10, 5, 1]
#   for batch_size in [10, 8]
#     for maxiters in [150]
#       for lr in [0.01]
#         for i in 1:5
#           println("images/steps_bin_$(bin_size)_batch_$(batch_size)_maxIters_$(maxiters)_lr_$(lr)_i_$(i)") 
#           pl = model(bin_size, batch_size, maxiters, lr)
#           savefig(pl, "images/bolus_and_steps_images/bolus_steps_bin_$(bin_size)_batch_$(batch_size)_maxIters_$(maxiters)_lr_$(lr)_i_$(i).png")
#         end
#       end
#     end
#   end
# end
