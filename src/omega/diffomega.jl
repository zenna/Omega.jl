struct CountVec{T}
  data::Vector{T}
  count::Int
end

"Differentiable Omega"
struct DiffOmega{T <: AbstractFloat}
  vals::Dict{Int, CountVec{T}}
end
