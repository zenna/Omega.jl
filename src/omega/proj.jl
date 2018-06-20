"Projection of `ω` onto compoment `id`"
struct ΩProj{O, I} <: Ω{I}
  ω::O
  id::I
end 

# function Base.rand(ωπ::ΩProj, ::Type{T}) where {T <: RV}
#   closeopen(T, ωπ)
# end 