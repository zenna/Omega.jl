using Mu

function testsum(;kwargs...)
  x = logistic(1.0, 1.0, (10,))
  y = sum(x)
  OmegaT = SimpleOmega{Int, Flux.TrackedArray}
  samples = rand(y, y == -1.0, HMCFAST, OmegaT = OmegaT; kwargs...)
end

testsum()