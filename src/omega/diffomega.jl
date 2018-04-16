"Differentiable Omega"
struct DiffOmega{T <: Real, I} <: Omega{I}
  vals::Dict{I, CountVec{T}}
end

resetcount!(dω::DiffOmega) = (foreach(resetcount!, values(dω.vals)); dω)
resetcount(dω::DiffOmega) = deepcopy(dω)

DiffOmega{T, I}() where {T, I} = DiffOmega(Dict{I, CountVec{T}}())
DiffOmega() = DiffOmega{Float64, Int}()

lookupme(::Type{CloseOpen}) = Float64

function Base.rand(::Type{T}, ωπ::OmegaProj{O}) where {T, T2, O <: DiffOmega{T2}}
  @assert false
  closeopen(lookupme(T), ωπ)
end

function closeopen(::Type{T}, ωπ::OmegaProj{O}) where {T, T2, O <: DiffOmega{T2}}
  # @show T
  # @assert false
  T3 = lookupme(T)
  cvec = get!(CountVec{T3}, ωπ.ω.vals, ωπ.id)
  next!(cvec, T)
end

## Conversions
## ==========

"Flatten `DiffOmega` into Vector"
function tovector(dω::DiffOmega{T}) where T
  vals = T[]
  for i in sort(collect(keys(dω.vals)))
    vals = vcat(vals, dω.vals[i].data)
  end
  vals
end

"Convert Vector to `DiffOmega``"
function todiffomega(xs::Vector{T1}, dω1::DiffOmega{T2, Int}) where {T1, T2}
  dω = DiffOmega{T1, Int}()
  lb = 1
  for i in sort(collect(keys(dω1.vals)))
    ub = lb + length(dω1.vals[i].data) - 1
    cvec = CountVec(xs[lb:ub])
    dω.vals[i] = cvec
    lb = ub + 1
  end
  dω
end
