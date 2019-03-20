"FailUnsat on condition"
struct FailUnsatAlg <: SamplingAlgorithm end

const FailUnsat = FailUnsatAlg()

isapproximate(::FailUnsatAlg) = false

"`n` samples from `x`"
function Base.rand(rng,
                   ΩT::Type{OT},
                   pred::RandVar,
                   n::Integer,
                   alg::FailUnsatAlg;
                   cb = donothing) where {OT <: Ω}
  ωsamples = ΩT[]
  accepted = 0
  for i = 1:n
    ω = ΩT()
    issat = pred(Omega.Space.tagrng(ω, rng))
    !issat && error("Condition unsatisfied. Use appropriate infrence alg.")
    push!(ωsamples, ω)
    cb((ω = ω, accepted = accepted, p = float(issat), i = i), IterEnd)
  end
  ωsamples
end
    
function Base.rand(rng::AbstractRNG,
                   x::RandVar,
                   n::Integer,
                   alg::FailUnsatAlg;
                   ΩT::Type{OT} = defΩ(alg),
                   cb = donothing) where {OT <: Ω}
  pred = Omega.indomain(x)
  ωsamples = rand(rng, ΩT, pred, n, alg; cb = cb)
  map(x, ωsamples)
end