struct FluxGradAlg <: GradAlg end
const FluxGrad = FluxGradAlg()

function back!(rv, ω, ::FluxGradAlg)
  l = rv(ω)
  Flux.back!(l)
end

# # FIXME: Remove this
# function gradient(::FluxGradAlg, U, sω::SimpleΩ{I, V}) where {I, V <: AbstractArray}
#   l = U(sω)
#   Flux.back!(l)
# end
# # The New #

lineargradient(rv, ω, ::FluxGradAlg) = (back!(rv, ω, FluxGrad); linearize(ω))
