# using Plots
using Omega
# using Parameters
# include(joinpath(dirname(pathof(Omega)), "viz.jl"))

function prob1()
  x = uniform(-1.0, 1.0)  
  y = uniform(-1.0, 1.0)
  (x = x, y = y, c = x ==ₛ y, xlims = (-1, 1), ylims = (-1, 1))
end

function prob2()
  x = uniform(-1.0, 1.0)
  y = uniform(-1.0, 1.0)
  (x = x, y = y, c = x >ₛ y, xlims = (-1, 1), ylims = (-1, 1))
end

function prob3()
  x = uniform(-1.0, 1.0)
  y = uniform(-1.0, 1.0)
  (x = x, y = y, c = abs(x) >ₛ abs(y), xlims = (-1, 1), ylims = (-1, 1))
end

function prob4()
  x = uniform(-1.0, 1.0)
  y = uniform(-1.0, 1.0)
  (x = x, y = y, c = x^2 ==ₛ y^2, xlims = (-1, 1), ylims = (-1, 1))
end

function prob5(k = 3, thresh = 0.9999)
  x = uniform(0.0, 1.0)
  y = uniform(0.0, 1.0)
  c = (sin(2π * x * k) * cos(2π * y * k)) >ₛ thresh
  (x = x, y = y, c = c, xlims = (0, 1), ylims = (0, 1))
end

function prob6(k = 3, thresh = 0.8)
  x = uniform(0, 1.0)
  y = uniform(0, 1.0)
  c = (sin(2π * x * k) * cos(2π * y * k)) >ₛ thresh
  (x = x, y = y, c = c, xlims = (0, 1), ylims = (0, 1))
end

function prob7(k = 3, thresh = 0.8)
  x = uniform(-1.0, 1.0)
  y = uniform(-100.0, 100.0)
  c = (x ==ₛ 0.0) & (y ==ₛ 0.0)
  (x = x, y = y, c = c, xlims = (-1, 1), ylims = (-100, 100))
end

# function allsamples(prob, n; algkwargs...)
#   # ωsamples = rand(defΩ(), logerr(prob.c), n, alg, kwargs...)
#   # xy = randtuple((prob.x, prob.yy))
#   # samples = map(ω -> applynotrackerr(x, ω), ωsamples)

#   # ωsamples = rand((prob.x, prob.y), prob.c, n; alg = alg, kwargs...)
#   # (ωsamples = ωsamples, samples = samples)
#   samples = rand((prob.x, prob.y), prob.c, n; algkwargs...)
#   (samples = samples, ωsamples = nothing)
# end

# function scatterxy(samples;
#                    label = nothing, legend = nothing, xlims = (-1, 1),
#                    ylims = (-1, 1), kwargs...)
#   xs, ys = ntranspose(samples)
#   scatter(xs, ys, label = label, legend = legend, xlims = xlims, ylims = ylims)
# end

# function vizall(probs, algs, n)
#   plots = []
#   for prob in probs
#     @unpack x, y, c, xlims, ylims = prob
#     push!(plots, ωcontour(err(c); label = nothing, legend = nothing,
#                                   colorbar = nothing))
#     for alg in algs
#       try
#         @unpack samples, ωsamples = allsamples(prob, n; alg...)
#         push!(plots, scatterxy(samples, xlims = xlims, ylims = ylims))
#       catch e
#         println("Failed")
#         display(e)
#         # rethrow(e)
#         push!(plots, plot())
#       end
#     end
#   end
#   plots
#   # plt = plot(plots..., layout = (length(probs), length(algs) + 1))
# end

# probs = [prob1(), prob2(), prob3(), prob4(), prob5(), prob6()]
# algs = [(alg = SSMH,),
#         (alg = NUTS,),
#         (alg = Replica, nreplicas = 4, inneralg = SSMH)
#         (alg = Replica, nreplicas = 4, inneralg = NUTS)
#         ]

# plots = vizall(probs, algs, 1000)

# function makeplots()
#   plt = plot(plots..., layout = (length(probs), length(algs) + 1),
#              markersize=0.01, tickfontsize=4)
# end

# # n = 8
# # temps = Omega.Inference.logtemps(n)
# # temps = [1e-9, 10000]
# # withkernel(kseα(temps[end])) do
# #   @unpack x, y, c = prob6()
# #   # p1 = ωcontour(err(c); label = nothing, legend = nothing);
# #   p2 = ωcontour(logerr(c); label = nothing, legend = nothing)
# #   # samples = rand((x, y), c, 100000; alg = Replica, nreplicas = 8, temps = temps)
# #   # p3 = scatterxy(samples, xlims = (0, 1), ylims = (0, 1))
# #   # plot(p1, p3, markersize = 0.01, aspectratio = 1)
# # end

x = normal(0, 1)
y = normal(0, 1)
# rand((x, y), x ==ₛ y, alg = Replica, inneralg = HMCFAST)
rand((x, y), x ==ₛ y, 1000, alg = HMCFAST)