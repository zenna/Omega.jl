import ForwardDiff
using Flux
using ZenUtils

"Gradient ∇Y()"
function gradient(Y::RandVar{Bool}, ω::Omega, vals = linearize(ω))
  Y(ω)
  #@show Y(ω), ω, vals
  unpackcall(xs) = Y(unlinearize(xs, ω)).epsilon
  ForwardDiff.gradient(unpackcall, vals)
  #@show ReverseDiff.gradient(unpackcall, vals)
end

function gradient(Y::RandVar{Bool}, sω::SimpleOmega{I, V}, vals) where {I, V <: AbstractArray}
  # @grab Y
  sω = typeof(sω)()
  l = epsilon(Y(sω))
  # @grab l
  # @grab sω
  Flux.back!(l)
  for v in values(sω.vals)
    @show v.grad
  end  
  @grab wow = linearize(sω)
  @assert false
end