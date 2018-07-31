using Omega
using Flux

function testsum(;kwargs...)
  x = logistic(1.0, 1.0, (10,))
  y = sum(x)
  ΩT = Omega.SimpleΩ{Vector{Int}, Flux.TrackedArray}
  samples = rand(y, y ≊ -1.0; alg = HMCFAST, ΩT = ΩT, kwargs...)
end

testsum()