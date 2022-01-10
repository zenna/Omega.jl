module Fail

export FailUnsat
import ..OmegaCore

"Fails on condition"
struct FailUnsatAlg end
const FailUnsat = FailUnsatAlg()

# Set default randalg to fail
OmegaCore.defrandalg(args...) = FailUnsat

"""
`n` samples of` ω ∈ ΩT` from from model.  Throws error if such that `pred`
"""
function randsample(rng,
                    ΩT::Type{OT},
                    pred,
                    n,
                    alg::FailUnsatAlg) where {OT <: Ω}
  ωsamples = ΩT[]
  ωsamples = Vector{ΩT}(undef, n)
  accepted = 0
  for i = 1:n
    ω = ΩT()
    issat = pred(tagrng(ω, rng))
    @inbounds ωsamples[i] = ω
    # lens(Loop, (ω = ω, accepted = accepted, p = float(issat), i = i))
  end
  ωsamples
end
    
function Base.rand(rng::AbstractRNG,
                   x::RandVar,
                   n::Integer,
                   alg::FailUnsatAlg;
                   ΩT::Type{OT} = defΩ(alg)) where {OT <: Ω}
  pred = Omega.indomain(x)
  ωsamples = rand(rng, ΩT, pred, n, alg)
  map(ω -> apl(x, ω), ωsamples)
end

end