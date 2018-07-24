
## Soft Evaluation
## ===============
Cassette.@context SoftExCtx
Cassette.metadatatype(::Type{<:SoftExCtx}, ::Type{<:Number}) = Omega.SoftBool

soft(::typeof(>)) = softgt
soft(::typeof(>=)) = softgt
soft(::typeof(<)) = softlt
soft(::typeof(<=)) = softlt
soft(::typeof(==)) = softeq

function soften(f, ctx, args...)
  @show args
  Cassette.tag(f(args...), ctx, soft(f)(args...))
end

function softboolop(f, ctx, args...)
  @show args
  args_ = Cassette.untag.(args, ctx)
  tags = Cassette.metadata.(args, ctx)
  Cassette.tag(f(args_...), ctx, f(tags...))
end

Cassette.execute(ctx::SoftExCtx, ::typeof(Base.:>), x, y) = soften(>, ctx, x, y)
Cassette.execute(ctx::SoftExCtx, ::typeof(Base.:>=), x, y) = soften(>=, ctx, x, y)
Cassette.execute(ctx::SoftExCtx, ::typeof(Base.:<), x, y) = soften(<, ctx, x, y)
Cassette.execute(ctx::SoftExCtx, ::typeof(Base.:<=), x, y) = soften(<=, ctx, x, y)
# Cassette.execute(::SoftExCtx, Base.:(==)(x, y) where {__CONTEXT__ <: SoftExCtx} = soften(==, __context__, x, y)

Cassette.execute(ctx::SoftExCtx{T}, ::typeof(Base.:!), x::Cassette.Tagged{T}) where {T} = softboolop(!, ctx, x)
Cassette.execute(ctx::SoftExCtx, ::typeof(Base.:&), x::Cassette.Tagged, y::Cassette.Tagged) = softboolop(&, ctx, x, y)
Cassette.execute(ctx::SoftExCtx, ::typeof(Base.:|), x::Cassette.Tagged, y::Cassette.Tagged) = softboolop(|, ctx, x, y)
Cassette.execute(ctx::SoftExCtx, ::typeof(Base.:⊻), x::Cassette.Tagged, y::Cassette.Tagged) = soften(⊻, ctx, x, y)

function softapply(f, args...)
  ctx = Cassette.withtagfor(SoftExCtx(), f)
  res = Cassette.overdub(ctx, f, args...)
  Cassette.metadata(res, ctx)
end