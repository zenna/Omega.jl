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
      println(UnicodePlots.lineplot(ys, alldata, title="Time vs p"))
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

# FIXME: Redundant, make this use plotscalsr
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

# FIXME: Redundant, make this use plotscalsr
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
      println(UnicodePlots.lineplot(ys, xs, title="Time vs $name"))
    end
  end
end

"Plot histogram of loss with UnicodePlots"
function plotscalar(key::Symbol, name, display_ = display)
  xs = Float64[]
  ys = Int[]

  innerplotω(data, stage) = nothing # Do nothing in other stages
  function innerplotrv(data, stage::Type{Outside})
    x_ = getfield(data, key)
    println("$name is:")
    display_(x_)
    push!(xs, x_)
    push!(ys, data.i)
    if !isempty(xs)
      println(UnicodePlots.lineplot(ys, xs, title="Time vs $name"))
    end
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