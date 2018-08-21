# Callback tree

"Callback Node"
struct CbNode{F, TPL <: Tuple}
  parent::F
  children::TPL
end

p → c::Tuple = CbNode(p, c)
p → c = CbNode(p, (c,))

datamerge(x, data) = nothing
datamerge(data1::NamedTuple, data2::NamedTuple) = merge(data1, data2)

trigger(data, child, stage) = nothing
trigger(data::NamedTuple, child, stage) = child(data, stage)

function (cbt::CbNode)(data, stage)
  data2 = datamerge(cbt.parent(data, stage), data)
  # @show typeof(data2)
  # @show typeof(cbt)
  for child in cbt.children
    trigger(data2, child, stage)
  end
end

# Either make rule be that we always pass whatever is on
# Or we could make it say only if we pass some value it is tricted

@inline idcb(x, stage) = x

"Inf found"
struct InfError <: Exception end

"NaNs found"
struct NaNError <: Exception end

## Common Tools
## ============
runall(f) = f
runall(fs::AbstractVector) = (data, stage) -> foreach(f -> handlesignal(f(data, stage)), fs)

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
  maxseen = -Inf
  minseen = Inf
  
  innerplotp(data, stage) = nothing # Do nothing in other stages
  function innerplotp(data, stage::Type{Outside})
    push!(alldata, data.p)
    push!(ys, data.i)
    if !isempty(alldata)
      println(lineplot(ys, alldata, title="Time vs p"))
    end
    if data.p > maxseen
      maxseen = data.p
      printstyled("\nNew max at id $(data.i): $(data.p)\n"; color = :light_blue)
    end
    if data.p < minseen
      minseen = data.p
      printstyled("\nNew min at id $(data.i): $(data.p)\n"; color = :light_blue)
    end
  end
end

"Scatter plot ω values with UnicodePlots"
function plotω(x::RandVar, y::RandVar)
  xωs = Float64[]
  yωs = Float64[]

  innerplotω(data, stage) = nothing # Do nothing in other stages
  function innerplotω(data, stage::Type{Outside})
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
function plotrv(x::RandVar, name = string(x), display_ = display)
  xs = []
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

function tracecb(::Type{T}, t = identity) where T
  ωs = T[]
  allωs = Vector{T}[]
  function f(qp, ::Type{Inside})
    push!(ωs, t(qp))
  end

  function f(data, ::Type{Outside})
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
  printstyled("\nacceptance ratio: $(data.accepted/float(data.i))\n",
              "Last p: $(data.p)\n";
              color = :light_blue)
end


"Stop if nans or Inf are present (-Inf) still permissible"
stopnanorinf(data, stage) = nothing
function stopnanorinf(data, stage::Type{Outside})
  if isnan(data.p)
    println("p is $(data.p)")
    throw(NaNError())
    return Stop
  elseif data.p == Inf
    println("p is $(data.p)")
    throw(InfError())
    return Stop
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
function throttle(f, timeout; leading = true, trailing = false) # From Flux (thanks!)
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
      @async try
        while (sleep(timeout); later != nothing)
          later()
          later = nothing
        end
      catch e
        rethrow(e)
      finally
        cooldown = true
      end
    elseif trailing
      later = () -> (result = f(args...; kwargs...))
    end

    return result
  end
end

"Higher order function that makes a callback run just once every n"
function everyn(callback, n::Integer)
  everyncb(data, stage) = nothing
  function everyncb(data, stage::Type{Outside})
    if data.i % n == 0
      return callback(data, stage)
    else
      nothing
    end
  end
  return everyncb
end

"Defautlt callbacks"
default_cbs(n) = runall([throttle(plotp(), 0.1),
                         showprogress(n),
                         throttle(printstats, 1.0),
                         stopnanorinf])

default_cbs_tpl(n) = (throttle(plotp(), 0.1),
                      showprogress(n),
                      throttle(printstats, 1.0),
                      stopnanorinf)

# default_cbs(n) = [plotp(),
#                   showprogress(n),
#                   printstats,
#                   stopnanorinf]