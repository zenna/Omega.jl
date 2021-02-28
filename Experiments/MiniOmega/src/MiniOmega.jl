module MiniOmega

using Cassette
import Base:~
export sample, unif, normal, pointwise, <|, rt, Ω

const ID = NTuple{N, Int} where N

"Ω maps primitives to values"
struct Ω
  data::Dict{Any, Any}
end

unif(id, ω) = ω[(unif, @show(id))]

"Standard uniform"
unif(ω) = unif(1, ω)

normal(id, ω) = ω[(normal, id)]

"Standard normal"
normal(ω) = normal(1, ω)

Base.getindex(ω::Ω, prim::Tuple{typeof(normal), I}) where I =
  get!(ω.data, prim, randn())

Base.getindex(ω::Ω, prim::Tuple{typeof(unif), I}) where I =
  get!(ω.data, prim, rand())

## Logpdf
logpdf(prim::Tuple{typeof(unif), I}, v) where I = 0.0
# logpdf(prim::Tuple{typeof(unif), I}, v) = 0.0
logpdf(ω::Ω) = sum(logpdf(ωi, vi) for (ωi, vi) in ω.data)

## Sampling

"Sample a random ω ∈ Ω"
sample(::Type{Ω}) = Ω(Dict{Any, Any}())
sample(f) = f(sample(Ω))

# unif(i::ID) = ω -> ω[(i)]

# "Single primitive random variable"
# unif(ω::Ω) = ω[(1,)]

## (Conditional) independence 

# Use cassette to augment enivonrment with extra state
Cassette.@context IIDCtx 

"""Conditionally independent and identically distributed given `shared` parents

Returns the `id`th element of an (exchangeable) sequence of random variables
that are identically distributed with `f` but conditionally independent given
random variables in `shared`.

This is essentially constructs a plate where all variables in shared are shared,
and all other parents are not.
"""
function iid(f, id::Integer)
  let ctx = IIDCtx(metadata = (id = (id,),))
    ω -> withctx(ctx, f, ω)
  end
end

Base.:~(x, y) = iid(y, x)

withctx(ctx, f, ω) = Cassette.overdub(ctx, f, ω)
function Cassette.overdub(ctx::IIDCtx, ::typeof(withctx), ctxinner, f, ω)
  # Merge the context
  id = (ctxinner.metadata.id..., ctx.metadata.id...)
  Cassette.overdub(IIDCtx(metadata = (id = id,)), f, ω)
end

Primitives = Union{typeof(unif), typeof(normal)}

# Intercept `unif(id, ω)`
Cassette.overdub(ctx::IIDCtx, f::T, id, ω::Ω) where T <: Primitives =
  f(ctx.metadata.id, ω)

## Plates

## A plate is any function of the form `f(id, ω)``

"`i`th member of plate `f`"
struct PlateMember{F, S}
  f::F
  i::S
end

@inline <|(f, i) = PlateMember(f, i)
(m::PlateMember)(ω) = m.f(m.i, ω)

## Syntactic Sugar (to make model-building nicer)

"Random tuple"
rt(fs...) = ω -> map(f -> f(ω), fs)

end
