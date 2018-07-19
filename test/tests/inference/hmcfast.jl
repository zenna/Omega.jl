using Omega

function testsum(;kwargs...)
  x = logistic(1.0, 1.0, (10,))
  y = sum(x)
  ΩT = SimpleΩ{Int, Flux.TrackedArray}
  samples = rand(y, y == -1.0, HMCFAST, ΩT = ΩT; kwargs...)
end

testsum()