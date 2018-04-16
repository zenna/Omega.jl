## Pairing Functions
## =================

"Cantour Pairing Function"
pair(k1, k2) = div((k1 + k2)*(k1 + k2 + 1), 2) + k2
pair(k1) = k1

# struct Paired{T}
#   val::T
# end

const Paired = Int
Base.getindex(ω::O, i::Int) where {O <: Omega{Paired}} = OmegaProj{O, Paired}(ω, pair(0, i))
Base.getindex(ωπ::OmegaProj{O, Paired}, i::Int) where O = OmegaProj{O, Paired}(ωπ.ω, pair(ωπ.id, i))