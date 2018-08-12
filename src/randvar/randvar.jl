"Random Variable: a function `Ω -> T`"
abstract type AbstractRandVar{T} end  # FIXME : Rename to RandVar

struct RandVar{T, Prim, F, TPL, I} <: AbstractRandVar{T} # Rename to PrimRandVar or PrimRv
  f::F      # Function (generally Callable)
  args::TPL # Arguments
  id::I     # Its id
end

function RandVar{T, Prim}(f::F, args::TPL, id::I) where {T, Prim, F, TPL, I}
  RandVar{T, Prim, F, TPL, I}(f, args, id)
end

function RandVar{T, Prim}(f::F, args::TPL) where {T, Prim, F, TPL}
  RandVar{T, Prim, F, TPL, Int}(f, args, uid())
end

function RandVar{T}(f::F) where {T, F}
  RandVar{T, true, F, Tuple{}, Int}(f, (), uid())
end

function Base.copy(x::RandVar{T}) where T
  RandVar{T}(x.f, x.ωids)
end

apply(f, xs...) = f(xs...)
# FIXME this loose type
(rv::RandVar)(xs...) = RandVar{Any, false}(apply, (rv, xs...))

"""Is `x` a constant random variable, i.e. x(ω) = c ∀ ω ∈ Ω?

Determining constancy is intractable (and likely undecidable) in general.
if `isconstant(x)` is true then `x` is constant, but if `isconstant(x)` is false,
`x` may still be constant, but we have failed to determine it.

```jldoctest
x1 = constant(0.3)
isconstant(x1)
true

x2 = ciid(ω -> 0.3)
isconstant(x2)
true

x3 = ciid(ω -> rand(ω))
isconstant(x3)
false

# False Negative
x3 = ciid(ω -> rand(ω) > 0.5 ? 0.3 : 0.3)
isconstant(x3)
false
```
"""
function isconstant(x, ΩT = defΩ(x))
  # This implementation assumes that ΩT is lazy, more general solution would wrap
  # ω of any type and intercept rand(ω) 
  ω = ΩT()
  x(ω)
  isempty(ω)
end

"Infer T from function `f: w -> T`"
function infer_elemtype(f, args...)
  @show argtypes = map(typeof, args)
  rt = Base.return_types(f, (defΩ(), argtypes...))
  @pre length(rt) == 1 "Could not infer unique return type"
  rt[1]
end

## Printing
## ========
name(x) = x
name(rv::RandVar) = string(rv.f)
Base.show(io::IO, rv::RandVar{T}) where T=
  print(io, "$(rv.id):$(name(rv))($(join(map(name, rv.args), ", ")))::$T")
