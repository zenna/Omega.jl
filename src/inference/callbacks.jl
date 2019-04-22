# FIXME:
# Remove explicit names from these callbacks and add connectors which extract from NT
# modularse.  Have one cb that accumuluates
# 

"""
```julia
using Lens
x = normal(0, 1)
@leval Loop => plotloss() rand(x, x >ₛ 0.0, 100; alg = SSMH)
"""
function plotloss(; title = "Loss vs Iteration", display_ = display, LTY::Type{TY} = Float64) where {TY}
  cb = Callbacks.plotscalar(; title = title, display_ = display_, LTX = Int, LTY = LTY)
  data -> cb((x = data.i, y = data.p))
end

"Scatter plot ω values with UnicodePlots"
function plotω(x::RandVar, y::RandVar, T = Float64)
  xωs = T[]
  yωs = T[]

  function innerplotω(data)
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

"Line Plot histogram of loss with UnicodePlots"
function plotscalar(key::Symbol, name, display_ = display, ::Type{T} = Float64) where T
  xs = T[]
  ys = Int[]
  maxseen = typemin(T)
  minseen = typemax(T)

  function innerplotrv(data)
    x_ = getfield(data, key)
    println("$name is:")
    display_(x_)
    push!(xs, x_)
    push!(ys, data.i)
    if !isempty(xs)
      println(UnicodePlots.lineplot(ys, xs, title="Time vs $name"))
    end
    if x_ > maxseen
      maxseen = x_
      printstyled("\nNew max at id $(data.i): $(x_)\n"; color = :light_blue)
    end
    if x_ < minseen
      minseen = x_
      printstyled("\nNew min at id $(data.i): $(data.p)\n"; color = :light_blue)
    end
  end
end

"Print acceptance statistics"
function printstats(data)
  printstyled("\nacceptance ratio: $(data.accepted/float(data.i))\n",
              "Last p: $(data.p)\n";
              color = :light_blue)
end

default_cbs_tpl(n) = (throttle(plotp(), 0.1),
                      showprogress(n),
                      throttle(printstats, 1.0),
                      stopnanorinf)

"Defautlt callbacks"
default_cbs(n) = runall([default_cbs_tpl(n)...])