"""Symbolic Omega"""
struct SymΩ{I} <: Space.ΩBase{I}
  # vals::Dict{I, V}
end

struct SymVal{K, V}
  val::NamedTuple{K, V}
end

Base.:*(x::SymVal, y::SymVal) =
  isindep(x, y) ? SymVal((mean = x.val.mean * y.val.mean, ig = x.val.ig ∪ y.val.ig)) : error("Cannot multiply expectatios of non-independent randvars")
Base.:+(x::SymVal, y::SymVal) = SymVal((mean = x.val.mean + y.val.mean, ig = x.val.ig ∪ y.val.ig))
Base.:+(x::SymVal, y) = SymVal((mean = x.val.mean + y, ig = x.val.ig))
Base.:+(x, y::SymVal) = SymVal((mean = x + y.val.mean, ig = y.val.ig))
Base.:-(x::SymVal, y) = SymVal((mean = x.val.mean - y, ig = x.val.ig))
Base.:-(x, y::SymVal) = SymVal((mean = x - y.val.mean, ig = y.val.ig))


S(::Type{T}) where T = Union{SymVal, T}

const SymΩProj = Space.ΩProj{SymΩ{ID}, ID} where ID

function Prim.normal(ωπ::SymΩProj, μ::Real, σ::Real)
  Space.randinc!(ωπ, SymVal((mean = μ, ig = Set([ωπ.id]))))
end

function Prim.normal(ωπ::SymΩProj, μ::SymVal, σ::SymVal)
  # @assert false
  Space.randinc!(ωπ, SymVal((mean = μ.val.mean, ig =  union(Set([ωπ.id]), μ.val.ig, σ.val.ig))))
end

function Prim.uniform(ωπ::SymΩProj, a::Real, b::Real)
  Space.randinc!(ωπ, SymVal((mean = (a + b)*0.5, ig = Set([ωπ.id]))))
end

"Independence Group"
struct IndepGroup
  ids::Set{ID}
end

IndepGroup(::ID) = IndepSet(id)

Base.union(x::IndepGroup, y::IndepGroup) = IndepGroup(union(x.ids, y.ids))
unionig(xs...) = union(xs...)
isintersect(x::Set, y::Set) = isempty(intersect(x, y))
isindep(x::Set, y::Set) = isintersect(x, y)
isindep(x::SymVal, y::SymVal) = isindep(x.val.ig, y.val.ig)

function analyticalmean(x)
  ω = SymΩ{ID}()
  x(ω).val.mean
end