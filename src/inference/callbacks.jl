using UnicodePlots

"Inf found"
struct InfError <: Exception end

"NaNs found"
struct NaNError <: Exception end

## Common Tools
## ============
runall(f) = f
runall(fs::AbstractVector) = (data, stage) -> foreach(f -> handlesignal(f(data, stage)), fs)

# Replace with named tuple in 0.7
struct RunData{O}
  ω::O
  accepted::Int
  p::Float64
  i::Int
end

"Stage of algorithm at which callback is called.
 Callback has type f(data, stage::Type{<:Stage}."
abstract type Stage end

""
abstract type Inside <: Stage end

"Stage at end of MHStep"
abstract type Outside <: Stage end


"Signal returned by callback"
abstract type Signal end
abstract type Stop <: Signal end

"Default handle signal (do nothing)"
handlesignal(x) = nothing
handlesignal(::Type{Stop}) = throw(InterruptException)

## Callback generators
## ===================
"Plot histogram of loss with UnicodePlots"
function plotp()
  alldata = Float64[]
  ys = Int[]
  
  innerplotp(data, stage) = nothing # Do nothing in other stages
  function innerplotp(data, stage::Type{Outside})
    push!(alldata, data.p)
    push!(ys, data.i)
    @show alldata
    if !isempty(alldata)
      println(lineplot(ys, alldata, title="Time vs p"))
    end
  end
end

"Scatter plot ω values with UnicodePlots"
function plotω(x::RandVar{T}, y::RandVar{T}) where T
  xωs = Float64[]
  yωs = Float64[]

  innerplotω(data, stage) = nothing # Do nothing in other stages
  function innerplotω(data, stage)
    color = :blue
    if isempty(xωs)
      color = :red
    end
    xω = data.ω.vals[x.id]
    yω = data.ω.vals[y.id]
    push!(xωs, xω)
    push!(yωs, yω)
    println(scatterplot(xωs, yωs, title="ω movement", color=color, xlim=[0, 1], ylim=[0, 1]))
  end
end

"Plot histogram of loss with UnicodePlots"
function plotrv(x::RandVar{T}, name = string(x), display_ = display) where T
  xs = T[]
  ys = Int[]

  innerplotω(data, stage) = nothing # Do nothing in other stages
  function innerplotrv(data, stage::Type{Outside})
    x_ = x(data.ω)
    println("$name is:")
    display_(x_)
    push!(xs, x_)
    push!(ys, data.i)
    if !isempty(xs)
      println(lineplot(ys, xs, title="Time vs $name"))
    end
  end
end

"Show progress meter"
function showprogress(n)
  p = Progress(n, 1)
  updateprogress(data, stage) = nothing # Do nothing in other stages
  function updateprogress(data, stage::Type{Outside})
    ProgressMeter.next!(p)
  end
end

"Construct callback that anneals temperature parameters"
function anneal(α::Var...)
  function (data, stage)
    foreach(α -> α * 0.95, αs)
  end
end

function tracecb(::Type{T}, t = identity) where T
  ωs = T[]
  allωs = Vector{T}[]
  function f(qp, ::Type{Mu.Inside})
    push!(ωs, t(qp))
  end

  function f(data, ::Type{Mu.Outside})
    push!(allωs, copy(ωs))
    empty!(ωs)
  end
  f, (ωs, allωs)
end


## Callbacks
## =========
"Print the p value"
printstats(data, stage) = nothing
function printstats(data, stage::Type{Outside})
  print_with_color(:light_blue, "\nacceptance ratio: $(data.accepted/float(data.i))\n",
                                "Last p: $(data.p)\n")
end


"Stop if nans or Inf are present"
stopnanorinf(data, stage) = nothing
function stopnanorinf(data, stage::Type{Outside})
  if isnan(data.p)
    println("p is $(data.p)")
    throw(NaNError())
    return Mu.Stop
  elseif isinf(data.p)
    println("p is $(data.p)")
    throw(InfError())
    return Mu.Stop
  end
end

"As the name suggests"
donothing(data, stage) = nothing

## Callback Augmenters
## ===================
#
"""
Returns a function that when invoked, will only be triggered at most once
during `timeout` seconds. Normally, the throttled function will run
as much as it can, without ever going more than once per `wait` duration;
but if you'd like to disable the execution on the leading edge, pass
`leading=false`. To enable execution on the trailing edge, ditto.
"""
function throttle(f, timeout; leading=true, trailing=false) # From Flux (thanks!)
  cooldown = true
  later = nothing
  result = nothing

  function throttled(args...; kwargs...)
    yield()

    if cooldown
      if leading
        result = f(args...; kwargs...)
      else
        later = () -> f(args...; kwargs...)
      end

      cooldown = false
      @schedule try
        while (sleep(timeout); later != nothing)
          later()
          later = nothing
        end
      finally
        cooldown = true
      end
    elseif trailing
      later = () -> (result = f(args...; kwargs...))
    end

    return result
  end
end

"Defautlt callbacks"
default_cbs(n) = [throttle(plotp(), 1.0),
                  showprogress(n),
                  throttle(printstats, 1.0),
                  stopnanorinf]