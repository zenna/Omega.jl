## Projection
## ==========
function Base.getindex(sω::SO, i::Int) where {I, SO <: ΩWOW{<:I}}
  ΩProj{SO, I}(sω, base(I, i))
end
