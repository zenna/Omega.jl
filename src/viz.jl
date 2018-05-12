using Plots
using Mu

"""
μ = normal(0.0, 1.0)
x = normal(μ, 1.0)
y = x == 0.0
viz(y)
"""
function ucontours(y::Mu.RandVar, xdim, ydim, ω::Mu.Omega; xrng = 0:0.01:1, yrng = 0:0.01:1, plt = plot())
  ω_ = deepcopy(ω)
  function f(x_, y_)
    # @show x, y, ω_
    ω_.vals[xdim] = x_
    ω_.vals[ydim] = y_
    Mu.epsilon(y(ω_))
  end
  # p = plot!(plt, xrng, yrng, f, st = [:contourf])
  p = contour!(plt, xrng, yrng, f, fill = false)
end


"x ∈ [0, 1]?"
isunit(x) = 0.0 <= x <= 1.0

function plottrace(data, plt = plot())
  d = [d.q for d in data]
  
  # FOR HMCFAST: TOOD Specialise
  xs = Mu.bound.([d_[1][1] for d_ in d])
  ys = Mu.bound.([d_[2][1] for d_ in d])
  # xs = Mu.bound.([d_[1] for d_ in d])
  # ys = Mu.bound.([d_[2] for d_ in d])

  plot!(plt, xs, ys, arrow = :arrow, linealpha = 0.5, legend=false)
end

function plottraces(qpdata, plt = plot())
  for qp in qpdata
    plottrace(qp, plt)
  end
  plt
end

function testcb(;ALG = HMC, n = 1000, kwargs...)
  μ = normal(0.0, 1.0)
  x = normal(μ, 1.0)
  y = (x == 0.0)  
  y = (x == 0.0) | (μ < 0.0)
  cb, cbdata = Mu.tracecb(Mu.QP, deepcopy)
  cb = [default_cbs(n); cb]
  rand(μ, y, ALG; n = n, cb = cb, kwargs...)
  qpdata = cbdata[2]
  plt = plot()
  ucontours(y, x.id, μ.id, Mu.defaultomega(HMC)(), plt = plt)
  plottraces(qpdata, plt)
end

testcb(nsteps = 20, stepsize = 0.01, n = 100)