import Flux
import Flux.Tracker

struct TrackerGradAlg <: GradAlg end
const TrackerGrad = TrackerGradAlg()

function back!(rv, ω, ::TrackerGradAlg)
  l = rv(ω)
  Flux.back!(l)
end

# # FIXME: Remove this
# function gradient(::TrackerGradAlg, U, sω::SimpleΩ{I, V}) where {I, V <: AbstractArray}
#   l = U(sω)
#   Flux.back!(l)
# end
# # The New #

function grad(rv, ω, ::TrackerGradAlg)
  Tracker.gradient(() -> rv(ω), Flux.params(ω))
end

function gradarray(rv, ω, ::TrackerGradAlg)
  vs = values(ω)
  grads_ = grad(rv, ω, vs, TrackerGrad)
  map(v -> grads_[v], vs)
end

lineargradient(rv, ω, ::TrackerGradAlg) = (back!(rv, ω, TrackerGrad); linearize(ω))

function value(x::Union{Tracker.Tracked,
                        Tracker.TrackedReal,
                        Tracker.TrackedArray,
                        Tracker.TrackedTuple})
  Tracker.data(x)
end