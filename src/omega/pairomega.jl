## Pairing Functions
## =================

"Cantour Pairing Function"
pair(k1, k2) = div((k2 + k2)*(k1 + k2 + 1), 2) + k2
pair(k1) = k1

# struct Paired{T}
#   val::T
# end

Paired = Int

Base.getindex(ω::Omega{T, Paired}, i::Int) where {T, O} = OmegaProj{O, Paired}(ω, 1)
Base.getindex(ωπ::OmegaProj{O, Paired}, i::Int) where O = OmegaProj{O, Paired}(ωπ.ω, pair(ωπ.id, i))
