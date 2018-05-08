using UnicodePlots

## Common Tools
## ============
runall(f) = f
runall(fs::AbstractVector) = (data) -> foreach(f -> handlesignal(f(data)), fs)

# Replace with named tuple in 0.7
struct RunData{O}
  ω::O
  accepted::Int
  p::Float64
  i::Int
end

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
  function innerplotp(data)
    push!(alldata, data.p)
    push!(ys, data.i)
    if !isempty(alldata)
      println(lineplot(ys, alldata, title="time vs p"))
    end
  end
end

"Show progress meter"
function showprogress(n)
  p = Progress(n, 1)
  function(data)
    ProgressMeter.next!(p)
  end
end

## Callbacks
## =========
"Print the p value"
function printstats(data)
  print_with_color(:light_blue, "\nacceptance ratio: $(data.accepted/float(data.i))\n",
                                "Last p: $(data.p)\n")
end

"Stop if nans are present"
function stopnan(data)
  if isnan(data.p)
    println("p is nan")
    Mu.Stop
  end
end

"As the name suggests"
donothing() = data -> nothing

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
                  stopnan]