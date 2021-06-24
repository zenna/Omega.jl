
# Temperature Modulation
const GLOBALKERNEL_ = Function[kse]

"Global Kernel"
function globalkernel!(k)
  global GLOBALKERNEL_
  GLOBALKERNEL_[1] = k
end

"Retrieve global kernel"
function globalkernel()
  global GLOBALKERNEL_
  GLOBALKERNEL_[1]
end

"Temporarily set global kernel"
function withkernel(thunk, k)
  globalkernel!(k)
  res = thunk()
  globalkernel!(kse)
  res
end

# Ctx Based Temperature Modulation

"Context for particular kernel "
struct KernelContext{K}
  kernel::K
end

"Evaluate f(args...) under kernels kc"
function ctxapl(kc::KernelContext, f, args...)
  old = getctx(:kernel)  # FIXME: What if kernel doesn't exist
  setctx!(:kernel, kc.kernel)
  res = f(args...)
  setctx!(:kernel, old)
  res
end

# function testkernelctx()
#   softgt(0.3, 0.2, kernel = globalkernel())
#   softgt(0.3, 0.2, kernel = getctx(:kernel))
# end

# (Cassette-based) Temperature Modulation
Cassette.@context AlphaCtx

"""
`f(args)` where temperature controlled with temperature `α`

```julia
x = normal(0.0, 1.0)
atα(10, rand, x ==ₛ 0.3)
```
"""
@inline function atα(α, f, args...)
  ctx = Cassette.disablehooks(AlphaCtx(metadata = α))
  Cassette.overdub(ctx, f, args...)
end

# @inline Cassette.overdub(ctx::AlphaCtx, ::typeof(kse), x, α) = kse(x, ctx.metadata)
@inline Cassette.overdub(ctx::AlphaCtx, ::typeof(globalkernel)) = kseα(ctx.metadata)


"""

```julia
x = normal(0.0, 1.0)
@atα 100 rand(y ==ₛ 0.0)
```
"""
macro atα(a, fexpr)
  :(atα($(esc(a)), $(esc.(fexpr.args)...)))
end
@pre fexpr.head == :call
