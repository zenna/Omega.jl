using Plots

"""
μ = normal(0.0, 1.0)
x = normal(μ, 1.0)
y = x == 0.0
viz(y)
"""
function ucontours2(y::Mu.RandVar, xdim, ydim, ω::Mu.Omega; xrng = 0:0.01:1, yrng = 0:0.01:1, plt = plot())
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
  xs = Mu.bound.([d[1] for d in d])
  ys = Mu.bound.([d[2] for d in d])
  plot!(plt, xs, ys, arrow = :arrow, linealpha = 0.5)
end

function plottraces(qpdata, plt = plot())
  for qp in qpdata
    plottrace(qp, plt)
  end
  plt
end

function testcb()
  μ = normal(0.0, 1.0)
  x = normal(μ, 1.0)
  y = x == 0.0
  cb, cbdata = Mu.tracecb(Mu.QP)
  n = 200
  cb = [default_cbs(n); cb]
  rand(μ, y, HMC; n = n, cb = cb, nsteps = 100, stepsize = 0.01)
  qpdata = cbdata[2]
  plt = plot()
  ucontours2(y, μ.id, x.id, Mu.defaultomega(HMC)(), plt = plt)
  plottraces(qpdata, plt)
end
