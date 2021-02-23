module OmegaReverseDiff

import ReverseDiff
import ..OmegaGrad
export ReverseDiffGrad

struct ReverseDiffGradAlg <: OmegaGrad.GradAlg end
const ReverseDiffGrad = ReverseDiffGradAlg()

function OmegaGrad.lineargradient(rv, ω, ::ReverseDiffGradAlg)
  @assert false "unimplemented"
end

function OmegaGrad.grad(rv, ω, ::ReverseDiffGradAlg)
  ReverseDiff.gradient(rv, ω)
end


"arrayω(rv) returns a function f where `f` has the form `f(::AbstractArray{<:Real})::Real`"
arrayω(f, Ω) = xs -> f(unroll(f, xs, Ω))

"ω::Ω with keys `k` and values `v`"
function ωzip(f, xs, Ω)
  keys_ = vars(f)
end



ReverseDiff.gradient(f, input, cfg::GradientConfig = GradientConfig(input))

end
