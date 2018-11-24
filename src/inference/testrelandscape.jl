using Omega
using UnicodePlots
using Flux

function relandscapeexample()
  x = normal(0.0, 1.0)
  y = normal(0.0, 1.0)
  isxy = x ==ₛ y
  ΩT =  SimpleΩ{Vector{Int}, Flux.TrackedArray}
  rand((x, y), isxy, 100, alg = Relandscape, ΩT = ΩT)
end

samples = relandscapeexample()