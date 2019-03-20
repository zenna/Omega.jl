# Cassette Based Memoization
Cassette.@context MemoizeCtx

function Cassette.overdub(ctx::MemoizeCtx, x::RandVar, args...)
  if x.id in keys(ctx.metadata)
    ctx.metadata[x.id]  
  else
    Cassette.recurse(ctx, x, args...)
  end
end

function Cassette.posthook(ctx::MemoizeCtx, retval, x::RandVar, args...)
  ctx.metadata[x.id] = retval
end

# Ω Based Memoization