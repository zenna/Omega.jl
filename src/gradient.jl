import ForwardDiff
using Flux
using ZenUtils

"Gradient ∇Y()"
function gradient(Y::RandVar, ω::Omega, vals = linearize(ω))
  Y(ω)
  #@show Y(ω), ω, vals
  unpackcall(xs) = -log(Y(unlinearize(xs, ω)).epsilon)
  ForwardDiff.gradient(unpackcall, vals)
  # @assert false
  #@show ReverseDiff.gradient(unpackcall, vals)
end

function gradient(Y::RandVar, sω::SimpleOmega{I, V}, vals) where {I, V <: AbstractArray}
  sω = unlinearize(vals, sω)
  sωtracked = SimpleOmega(Dict(i => param(v) for (i, v) in sω.vals))
  # @grab vals
  l = -epsilon(Y(sωtracked))
  @grab sωtracked
  # @grab Y
  # @grab l
  # @assert false
  @assert !(isnan(l))
  Flux.back!(l)
  totalgrad = 0.0
  @grab sωtracked
  for v in values(sωtracked.vals)
    @assert !(any(isnan(v)))

    @assert !(any(isnan(v.grad)))
    totalgrad += mean(v.grad)
  end
  # @show totalgrad
  sω_ = SimpleOmega(Dict(i => v.data for (i, v) in sωtracked.vals))
  linearize(sω_)
end

function fluxgradient(Y::RandVar{Bool}, sω::SimpleOmega{I, V}) where {I, V <: AbstractArray}
  l = -logepsilon(Y(sω))
  Flux.back!(l)
end