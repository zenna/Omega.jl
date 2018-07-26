
## Soft Evaluation
## ===============
Cassette.@context SoftExCtx
Cassette.metadatatype(::Type{<:SoftExCtx}, ::Type{Bool}) = Omega.SoftBool

soft(::typeof(>)) = softgt
soft(::typeof(>=)) = softgt
soft(::typeof(<)) = softlt
soft(::typeof(<=)) = softlt
soft(::typeof(==)) = softeq

function soften(f, ctx, args...)
  println(f, args)
  Cassette.tag(f(args...), ctx, soft(f)(args...))
end

function softboolop(f, ctx, args...)
  args_ = Cassette.untag.(args, ctx)
  tags = Cassette.metadata.(args, ctx)
  Cassette.tag(f(args_...), ctx, f(tags...))
end

Softable{T} = Union{Number, Array{T}} where T <: Number

Cassette.execute(ctx::SoftExCtx, ::typeof(Base.:>), x::Softable, y::Softable) = soften(>, ctx, x, y)
Cassette.execute(ctx::SoftExCtx, ::typeof(Base.:>=), x::Softable, y::Softable) = soften(>=, ctx, x, y)
Cassette.execute(ctx::SoftExCtx, ::typeof(Base.:<), x::Softable, y::Softable) = soften(<, ctx, x, y)
Cassette.execute(ctx::SoftExCtx, ::typeof(Base.:<=), x::Softable, y::Softable) = soften(<=, ctx, x, y)
# Cassette.execute(ctx::SoftExCtx, ::typeof(Base.:(==)), x::Softable, y::Softable) = soften(==, ctx, x, y)

Cassette.execute(ctx::SoftExCtx{T}, ::typeof(Base.:!), x::Cassette.Tagged{T}) where {T} = softboolop(!, ctx, x)
Cassette.execute(ctx::SoftExCtx{T}, ::typeof(Base.:&), x::Cassette.Tagged{T}, y::Cassette.Tagged{T}) where {T} = softboolop(&, ctx, x, y)
Cassette.execute(ctx::SoftExCtx{T}, ::typeof(Base.:|), x::Cassette.Tagged{T}, y::Cassette.Tagged{T}) where {T} = softboolop(|, ctx, x, y)
Cassette.execute(ctx::SoftExCtx{T}, ::typeof(Base.:⊻), x::Cassette.Tagged{T}, y::Cassette.Tagged{T}) where {T} = softboolop(⊻, ctx, x, y)

function softapply(f, args...)
  ctx = Cassette.withtagfor(SoftExCtx(), f)
  res = Cassette.overdub(ctx, f, args...)
  Cassette.metadata(res, ctx)
end