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
  @show sωtracked = SimpleOmega(Dict(i => param(v) for (i, v) in sω.vals))
  @show l = epsilon(Y(sωtracked))
  Flux.back!(l)
  for v in values(sωtracked.vals)
    @show v.grad
  end
  sω_ = SimpleOmega(Dict(i => v.data for (i, v) in sωtracked.vals))
  linearize(sω_)
end