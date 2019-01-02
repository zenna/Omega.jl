import ForwardDiff
using Flux

"Gradient ∇Y()"
function gradient(y::RandVar, ω::Ω, vals = linearize(ω))
  # y(ω)
  indomainₛ(y, ω)
  function unpackcall(xs)
    -logerr(indomainₛ(y, unlinearize(xs, ω)))
  end
  ForwardDiff.gradient(unpackcall, vals)
end

function gradient(y::RandVar, sω::SimpleΩ{I, V}, vals) where {I, V <: AbstractArray}
  @assert false
  sω = unlinearize(vals, sω)
  sωtracked = SimpleΩ(Dict(i => param(v) for (i, v) in sω.vals))
  # @grab vals
  l = -err(y(sωtracked))
  # @grab sωtracked
  # @grab y
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

function fluxgradient(U, sω::SimpleΩ{I, V}) where {I, V <: AbstractArray}
  l = U(sω)
  Flux.back!(l)
end