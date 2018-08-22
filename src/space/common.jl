## Projection
## ==========
function Base.getindex(sω::SO, i::I) where {I, SO <: ΩBase{<:I}}
  @show SO
  @show i
  # @assert false
  ΩProj{SO, I}(sω, base(I, i))
end
