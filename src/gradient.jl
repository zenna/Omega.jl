import ForwardDiff
using Flux

"Gradient ∇Y()"
function gradient(Y::RandVar, ω::Ω, vals = linearize(ω))
  Y(ω)
  #@show Y(ω), ω, vals
  unpackcall(xs) = -logepsilon(Y(unlinearize(xs, ω)))
  ForwardDiff.gradient(unpackcall, vals)
end

function gradient(Y::RandVar, sω::SimpleΩ{I, V}, vals) where {I, V <: AbstractArray}
  @assert false
  sω = unlinearize(vals, sω)
  sωtracked = SimpleΩ(Dict(i => param(v) for (i, v) in sω.vals))
  # @grab vals
  l = -epsilon(Y(sωtracked))
  # @grab sωtracked
  # @grab Y
  # @grab l
  # @assert false
  @assert !(isnan(l))
  Flux.back!(l)
  totalgrad = 0.0
  # @grab sωtracked
  for v in values(sωtracked.vals)
    @assert !(any(isnan(v)))

    @assert !(any(isnan(v.grad)))
    totalgrad += mean(v.grad)
  end
  # @show totalgrad
  sω_ = SimpleΩ(Dict(i => v.data for (i, v) in sωtracked.vals))
  linearize(sω_)
end

function fluxgradient(Y::RandVar, sω::SimpleΩ{I, V}) where {I, V <: AbstractArray}
  @assert false
  l = -logepsilon(Y(sω))
  Flux.back!(l)
end