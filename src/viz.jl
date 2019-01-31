using Plots
using Omega
import Omega.Space
using Omega.Space: getdim

"""
Contour Plot of two dimensions of Ω

```
x = normal(0.0, 1.0)
y = normal(0.0, 1.0)
c1 = err(x ==ₛ y)
c2 = err(x >ₛ y)
ωcontour(c2)
```

"""
function ωcontour(xrv::RandVar;
                  ΩT = defΩ(),
                  xdim = 1,
                  ydim = 2,
                  xrng = 0:0.005:1,
                  yrng = 0:0.005:1,
                  plt = plot(),
                  fill = true,
                  kwargs...)
  ω = ΩT()
  xrv(ω)
  function f(x, y)
    ω = Space.update(ω, xdim, x)
    ω = Space.update(ω, ydim, y)
    xrv(ω)
  end
  contour!(plt, xrng, yrng, f; fill = fill, kwargs...)
end

# "x ∈ [0, 1]?"
# isunit(x) = 0.0 <= x <= 1.0

"Plot path in Omega Space from sequence of samples"
function ωtrace(ωs::Vector;
                   xdim = 1,
                   ydim = 2,
                   plt = plot())
  xs, ys = ntranspose(map(ω -> (getdim(ω, xdim), getdim(ω, ydim)), ωs))
  plot!(plt, xs, ys, arrow = :arrow, linealpha = 0.5, legend = false)  
end


# function plottraces(qpdata, plt = plot())
#   for qp in qpdata
#     plottrace(qp, plt)
#   end
#   plt
# end

# function testcb2(;alg = HMC, n = 1000, kwargs...)
#   μ = normal(0.0, 1.0)
#   x = normal(μ, 1.0)
#   y = (x ==ₛ 0.0)  
#   # y = (x == 0.0) | (μ < 0.0)
#   cb, cbdata = Omega.tracecb(Omega.QP, deepcopy)
#   # cb = [default_cbs(n); cb]
#   rand(μ, y, n; alg = alg, cb = cb, kwargs...)
#   qpdata = cbdata[2]
#   plt = plot()
#   ωcontour(y, x.id, μ.id, Omega.defΩ(HMC)(), plt = plt)
#   print(plottraces(qpdata, plt))
#   qpdata, plt
# end

# testcb(nsteps = 20, stepsize = 0.01, n = 10000)

# function testcb2(;kwargs...)
#   μ = normal(0.0, 1.0)
#   x = normal(μ, 1.0)
#   # y = (x == 0.0) | (μ < 0.0)
#   y = (x^2 + μ^2 == 1.0)
#   cb, cbdata = Omega.tracecb(Omega.QP)
#   cb = [default_cbs(n); cb]
#   rand(μ, y, HMC; n = n, cb = cb, kwargs...)
#   qpdata = cbdata[2]
#   plt = plot()
#   ωcontour(y, x.id, μ.id, Omega.defΩ(HMC)(), plt = plt)
#   plottraces(qpdata, plt)
#   qpdata, plt
# end
# # qpdata, plt = testcb2(nsteps = 20, stepsize = 0.01, n=5000)

# function to_output_space(q1, q2)
#   n1  = Distributions.Normal(0, 1)
#   μ = quantile(n1, q1)
#   n2 = Distributions.Normal(μ, 1)
#   μ, quantile(n2, q2)
# end


# # function plotoutput(data, i=0,plt = plot())
# #   transf(d) = to_output_space(d.q |> Omega.inv_transform)...)[2]
# #   ys = map(transf, data)
# #   k = 1.0/(data |> length)
# #   xs = i:k:(i+1-k)
# #   plot!(plt, xs, ys, arrow = :arrow, linealpha = 0.5, legend=false)
# # end

# function plotoutputs(data, plt=plot())
#   for (i, qp) in enumerate(data)
#     plotoutput(qp, i, plt)
#   end
#   plt
# end

# function plotoutputXY(data, plt = plot())
#   xs, ys = zip([g((d.q |> Omega.inv_transform)...)               
#                 for d in data]...) |> collect
#   plot!(plt, xs |> collect, ys |> collect, arrow = :arrow, linealpha = 0.5, legend=false)
# end

# function plotoutputsXY(data, plt=plot())
#   foreach(data) do qp
#     plotoutputXY(qp, plt)
#   end
#   plt
# end

# function filtered_qp(qpdata)
#   indexes = filter(1:length(qpdata)-1) do i
#     qpdata[i][1].q != qpdata[i+1][1].q
#   end
#   qpdata[indexes]
# end
  
