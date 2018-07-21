using Plots
using Omega

"""
μ = normal(0.0, 1.0)
x = normal(μ, 1.0)
y = x == 0.0
viz(y)
"""
function ucontours(y::Omega.RandVar, xdim, ydim, ω::Omega.Ω; xrng = 0:0.01:1, yrng = 0:0.01:1, plt = plot())
  ω_ = deepcopy(ω)
  function f(x_, y_)
    # @show x, y, ω_
    ω_.vals[xdim] = x_
    ω_.vals[ydim] = y_
    Omega.epsilon(y(ω_))
  end
  # p = plot!(plt, xrng, yrng, f, st = [:contourf])
  p = contour!(plt, xrng, yrng, f, fill = false)
end


"x ∈ [0, 1]?"
isunit(x) = 0.0 <= x <= 1.0

function plottrace(data, plt = plot())
  d = [d.q for d in data]
  
  # FOR HMCFAST: TOOD Specialise
  xs = Omega.bound.([d_[1][1] for d_ in d])
  ys = Omega.bound.([d_[2][1] for d_ in d])
  # xs = Omega.bound.([d_[1] for d_ in d])
  # ys = Omega.bound.([d_[2] for d_ in d])

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
  # y = (x == 0.0) | (μ < 0.0)
  cb, cbdata = Omega.tracecb(Omega.QP, deepcopy)
  cb = [default_cbs(n); cb]
  rand(μ, y, ALG; n = n, cb = cb, kwargs...)
  qpdata = cbdata[2]
  plt = plot()
  ucontours(y, x.id, μ.id, Omega.defaultomega(HMC)(), plt = plt)
  print(plottraces(qpdata, plt))
  qpdata, plt
end

testcb(nsteps = 20, stepsize = 0.01, n = 10000)

function testcb2(;kwargs...)
  μ = normal(0.0, 1.0)
  x = normal(μ, 1.0)
  # y = (x == 0.0) | (μ < 0.0)
  y = (x^2 + μ^2 == 1.0)
  cb, cbdata = Omega.tracecb(Omega.QP)
  cb = [default_cbs(n); cb]
  rand(μ, y, HMC; n = n, cb = cb, kwargs...)
  qpdata = cbdata[2]
  plt = plot()
  ucontours(y, x.id, μ.id, Omega.defaultomega(HMC)(), plt = plt)
  plottraces(qpdata, plt)
  qpdata, plt
end
qpdata, plt = testcb2(nsteps = 20, stepsize = 0.01, n=5000)

function to_output_space(q1, q2)
  n1  = Distributions.Normal(0, 1)
  μ = quantile(n1, q1)
  n2 = Distributions.Normal(μ, 1)
  μ, quantile(n2, q2)
end


# function plotoutput(data, i=0,plt = plot())
#   transf(d) = to_output_space(d.q |> Omega.inv_transform)...)[2]
#   ys = map(transf, data)
#   k = 1.0/(data |> length)
#   xs = i:k:(i+1-k)
#   plot!(plt, xs, ys, arrow = :arrow, linealpha = 0.5, legend=false)
# end

function plotoutputs(data, plt=plot())
  for (i, qp) in enumerate(data)
    plotoutput(qp, i, plt)
  end
  plt
end

function plotoutputXY(data, plt = plot())
  xs, ys = zip([g((d.q |> Omega.inv_transform)...)               
                for d in data]...) |> collect
  plot!(plt, xs |> collect, ys |> collect, arrow = :arrow, linealpha = 0.5, legend=false)
end

function plotoutputsXY(data, plt=plot())
  foreach(data) do qp
    plotoutputXY(qp, plt)
  end
  plt
end

function filtered_qp(qpdata)
  indexes = filter(1:length(qpdata)-1) do i
    qpdata[i][1].q != qpdata[i+1][1].q
  end
  qpdata[indexes]
end
  
