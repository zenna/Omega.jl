"Vector with pointer to element"
struct CountVec{T <: AbstractFloat}  
  data::Vector{T}
  count::Int
end

CountVec(xs::Vector{T}) where T = CountVec{T}(xs, 1)
function next!(cv::CountVec)
  if cv.i < length(cv.data)
    cv.data[cv.i]
  else
  end 
end
reset!(cv::CountVec) = cv.count = 1

"Differentiable Omega"
struct DiffOmega{T <: AbstractFloat}
  vals::Dict{Int, CountVec{T}}
end

DiffOmega{T}() where T = DiffOmega(Dict{Int, CountVec{T}}())

@generated function closeopen(::Type{T}, ωπ::OmegaProj{DiffOmega{T2}}) where {T, T2}
  T2, T2Sym = lookup(T)
  quote
  cvec = get!(CountVec{T}, ωπ.ω.vals, ωπ.id)
  next!(cvec)
  end
end
