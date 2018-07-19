"Differentiable Ω"
struct DiffΩ{T <: Real, I} <: Ω{I}
  vals::Dict{I, CountVec{T}}
end

function Base.copy(dω::DiffΩ{T, I}) where {T, I}
  DiffΩ{T, I}(Dict{I, CountVec{T}}(k => copy(v) for (k, v) in dω.vals))
end

function resetcount(dω::DiffΩ{T, I}) where {T, I}
  DiffΩ{T, I}(Dict{I, CountVec{T}}(k => resetcount(v) for (k, v) in dω.vals))
end

resetcount!(dω::DiffΩ) = foreach(resetcount!, values(dω.vals))

## Rand
## ====

DiffΩ{T, I}() where {T, I} = DiffΩ(Dict{I, CountVec{T}}())
DiffΩ() = DiffΩ{Float64, Int}()

lookupme(::Type{CloseOpen}) = Float64

Base.rand(T, ω::DiffΩ) = rand(T, ω[0])
Base.rand(ω::DiffΩ, T) = rand(ω[0], T)

function Base.rand(::Type{T}, ωπ::ΩProj{O}) where {T, T2, O <: DiffΩ{T2}}
  @assert false
  closeopen(lookupme(T), ωπ)
end

function closeopen(::Type{T}, ωπ::ΩProj{O}) where {T, T2, O <: DiffΩ{T2}}
  T3 = lookupme(T)
  dω = ωπ.ω.vals[ωπ.ω.id]
  cvec = get!(CountVec{T3}, dω.vals, ωπ.id)
  next!(cvec, T)
end

## Conversions
## ===========

"Flatten `DiffΩ` into Vector"
function linearize(dω::DiffΩ{T}) where T
  vals = T[]
  for i in sort(collect(keys(dω.vals)))
    vals = vcat(vals, dω.vals[i].data)
  end
  vals
end

"Convert Vector to `DiffΩ``"
function unlinearize(xs::Vector{T1}, dω1::DiffΩ{T2, Int}) where {T1, T2}
  dω = DiffΩ{T1, Int}()
  lb = 1
  for i in sort(collect(keys(dω1.vals)))
    ub = lb + length(dω1.vals[i].data) - 1
    cvec = CountVec(xs[lb:ub])
    dω.vals[i] = cvec
    lb = ub + 1
  end
  dω
end
