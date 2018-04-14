"Differentiable Omega"
struct DiffOmega{T <: AbstractFloat, I} <: Omega{I}
  vals::Dict{I, CountVec{T}}
end

DiffOmega{T, I}() where {T, I} = DiffOmega(Dict{I, CountVec{T}}())
DiffOmega() = DiffOmega{Float64, Int}()

function Base.rand(::Type{T}, ωπ::OmegaProj{O}) where {T, T2, O <: DiffOmega{T2}}
  cvec = get!(CountVec{T}, ωπ.ω.vals, ωπ.id)
  next!(cvec, T)
end