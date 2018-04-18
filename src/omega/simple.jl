struct ValueTuple
  _Float64::Float64
  _Float32::Float32
  _UInt32::UInt32
end

"""
Fast SimpleOmega

# Properties
- Fast tracking (50 ns overhead)
- Fast to get linear view
- Hence easy to sample from
- Unique index for each rand value and hence:
  (i) Memory intensive
  (ii) Will give wrong results if not indexed corretly
"""
struct SimpleOmega{I, V} <: Omega{I}
  vals::Dict{I, V}
end

SimpleOmega() = SimpleOmega(Dict{Vector{Int}, Float64}())
SimpleOmega{I, V}() where {I, V} = SimpleOmega{I, V}(Dict{I, V}())

linearize(sω::SimpleOmega) = collect(values(sω.vals)) 

using ZenUtils
function unlinearize(ωvec::Vector, sω::SimpleOmega)
  # Keys not sorted, might be wrong
  @grab ωvec
  @grab sω
  SimpleOmega(Dict(k => ωvec[i] for (i, k) in enumerate(keys(sω.vals))))
end

function Base.getindex(sω::SO, i::Int) where {I, SO <: SimpleOmega{<:I}}
  OmegaProj{SO, I}(sω, base(I, i))
end

function Base.rand(ωπ::OmegaProj{O}, ::Type{T}) where {T, I, O <: SimpleOmega{I, <:Real}}
  get!(()->rand(Base.GLOBAL_RNG, T), ωπ.ω.vals, ωπ.id)
end

function (rv::RandVar{T, true})(ω::SimpleOmega) where T
  args = map(a->apl(a, ω), rv.args)
  (rv.f)(ω[rv.id], args...)
end

function (rv::RandVar{T, false})(ω::SimpleOmega) where T
  args = map(a->apl(a, ω), rv.args)
  (rv.f)(args...)
end

function Base.merge!(sω1::SimpleOmega, sω2::SimpleOmega)
  for (k, v) in sω2.vals
    sω1.vals[k] = v
  end
  sω1
end

Base.merge!(ωπ1::OmegaProj{O}, ωπ2::OmegaProj{O}) where {O <: SimpleOmega} =
  merge!(ωπ1.ω, ωπ2.ω)
