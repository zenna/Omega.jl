## Projection
## ==========
function Base.getindex(sω::SO, i::I) where {I, SO <: ΩWOW{<:I}}
  @show SO
  @show i
  # @assert false
  ΩProj{SO, I}(sω, base(I, i))
end
