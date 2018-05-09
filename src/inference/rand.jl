"Unconditional Sample from `x`"
function Base.rand(x::Union{RandVar, UTuple{RandVar}}; OmegaT::Type{T} = defaultomega()) where T <: Omega
  x(OmegaT())
end
# const DefaultOmega = Mu.SimpleOmega{Mu.Paired, Mu.Float64}
const DefaultOmega = Mu.SimpleOmega{Mu.Paired, Mu.ValueTuple}
defaultomega() = DefaultOmega

defaultomega(::Type{ALG}) where ALG = DefaultOmega

"Sample from `x | y == true` with Metropolis Hasting"
function Base.rand(x::Union{RandVar, UTuple{RandVar}}, y, alg::Type{ALG};
                   n::Integer = 1000,
                   OmegaT::OT = defaultomega(ALG),
                   cb = default_cbs(n)) where {ALG, OT}
  map(x, rand(OmegaT, y, alg; n = n, cb = cb))
end
