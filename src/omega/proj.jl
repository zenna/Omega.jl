"Projection of `ω` onto compoment `id`"
struct OmegaProj{O, I} <: Omega{I}
  ω::O
  id::I
end 

# function Base.rand(ωπ::OmegaProj, ::Type{T}) where {T <: RV}
#   closeopen(T, ωπ)
# end 