using Omega
using UnicodePlots
using Flux
using Rotations
# using Plots

function relandscapeexample()
  x = normal(0.0, 1.0)
  y = normal(0.0, 1.0)
  isxy = x ==ₛ y
  ΩT =  SimpleΩ{Vector{Int}, Flux.TrackedArray}
  rand((x, y), isxy, 100, alg = Relandscape, ΩT = ΩT)
end

# samples = relandscapeexample()
# UnicodePlots.densityplot(ntranspose(samples)...)

function relandscapeexample(n = 100)
  x = uniform(0.0, 1.0)
  y = uniform(0.0, 1.0)
  isxy = x >=ₛ y
  ΩT =  SimpleΩ{Vector{Int}, Flux.TrackedArray}
  rand((x, y), isxy, n, alg = Relandscape, ΩT = ΩT), x, y
end

function relandscapeexample(n = 100)
  x = uniform(0.0, 1.0)
  y = uniform(0.0, 1.0)
  isxy = abs(x - y) <ₛ 0.01
  ΩT =  SimpleΩ{Vector{Int}, Flux.TrackedArray}
  rand((x, y), isxy, n, alg = Relandscape, ΩT = ΩT), x, y
end


# samples, x, y = relandscapeexample(3)
# xy = randtuple((x, y))
# xysamples = xy.(samples)
# xyflat = map(tpl -> map(Flux.data, tpl), xysamples)
# UnicodePlots.densityplot(ntranspose(xyflat)...)

mat(f; r = 0.1) = [f(x, y) for x in 0:r:1, y in 0:r:1]
epsa = 1e-5
function matw(f; r = 0.1, ω = defΩ()())
  n = length(0+epsa:r:1-epsa)
  arr = Array{Float64}(undef, n, n)
  f(ω) # init
  xid, yid = keys(ω)
  for x in 1:n, y in 1:n
    ω.vals[xid] = x/n
    ω.vals[yid] = y/n
    arr[x, y] = f(ω)
  end
  arr
end

samples, x, y = relandscapeexample(2)
ω = defΩ()()
U_grab(ω)
wave_grab(ω)
r = 0.001
mata = matw(U_grab; r=r, ω = ω)
# mata = matw(wave_grab; r=r, ω = ω)

@show argmax(mata)
@show maximum(mata)
# contour(exp.(mata))
# contour(mata)

rng = 0+epsa:r:1-epsa

using Makie: surface
import Makie

Makie.surface!(
  rng, rng, exp.(mata),
  # colormap = :Spectral
)

Makie.contour(
  rng, rng, exp.(mata),
  colormap = :Spectral
)
