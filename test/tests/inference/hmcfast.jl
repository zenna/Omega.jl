using Mu

function testsum(;kwargs...)
  x = logistic(1.0, 1.0, (2,))
  y = sum(x)
  # OmegaT = SimpleOmega{Int, Array}
  OmegaT = SimpleOmega{Int, Flux.TrackedArray}
  samples = rand(y, y == 1.0, HMCFAST, OmegaT = OmegaT; kwargs...)
end

testsum()

function testsum2(;kwargs...)
  x = [logistic(1.0, 1.0) for i = 1:2]
  y = sum(x)
  OmegaT = SimpleOmega{Int, Float64}
  samples = rand(y, y == 1.0, HMC, OmegaT = OmegaT; kwargs...)
end

testsum2()