# module Pointwise

export pw, l, dl, ₚ, PwVar, liftapply
 
"""
Pointwise application.

Pointwise function application gives meaning to expressions such as `x + y`  when `x` and `y` are functions.
That is `x + y` is the function `ω -> x(ω) + y(ω)`.

An argument can be either __lifted__ or __not lifted__.
For example in `x = 1 ~  Normal(0, 1); y = pw(+, x, 3)`, `x` will be lifted but `3` will not be in the sense that
`y` will resolve to `ω -> x(ω) + 3` and not `ω -> x(ω) + 3(ω)`.

`pw` uses some reasonable defaults for what to lift and what not to lift, but to have more explicit control use `l` and `dl` to
lift and dont lift respectively.

Example:
```
using OmegaCore
x = StdUniform()
y = pw(+, x, 4)

f(ω) = Flip()(ω) ? sqrt : sin
sample(pw(map, f, [0, 1, 2]))
sample(pw(map, sqrt, [0, 1, 2])) # Will error!
sample(pw(map, dl(sqrt), [0, 1, 2]))
sample(pw(l(f), 3))
```
"""

struct PwVar{ARGS, D}
  f::D
  args::ARGS
  PwVar(f::F, args::A) where {F, A} = new{A, F}(f, args)
  PwVar(f::Type{T}, args::A) where {T, A} = new{A, Type{T}}(f, args)
end

pw(f) = (args...) -> PwVar(f, args)
pw(f, arg, args...) = PwVar(f, (arg, args...))
Base.show(io::IO, p::PwVar) = print(io, p.f, "ₚ", p.args)

abstract type ABox end

struct LiftBox{T} <: ABox
  val::T
end
"`l(x)` constructs object that indicates that `x` should be applied pointwise.  See `pw`"
l(x) = LiftBox(x)

struct DontLiftBox{T} <: ABox
  val::T
end
"`dl(x)` constructs object that indicates that `x` should be not applied pointwise.  See `pw`"
dl(x) = DontLiftBox(x)

# Traits
struct Lift end
struct DontLift end

# Trait functions
traitlift(::Type{T}) where T  = DontLift()
traitlift(::Type{<:Function}) = Lift()
traitlift(::Type{<:Variable}) = Lift()
traitlift(::Type{<:Member}) = Lift()
traitlift(::Type{<:Mv}) = Lift()
traitlift(::Type{<:DataType}) = DontLift()
traitlift(::Type{<:LiftBox}) = Lift()
traitlift(::Type{<:PwVar}) = Lift()
traitlift(::Type{<:DontLiftBox}) = DontLift()

@inline liftapply(f::T, ω) where T = liftapply(traitlift(T), f, ω)
@inline liftapply(::DontLift, f, ω) = f
@inline liftapply(::DontLift, f::ABox, ω) = f.val
@inline liftapply(::Lift, f, ω) = f(ω)
@inline liftapply(::Lift, f::ABox, ω) = (f.val)(ω)
@inline liftapply(::Lift, f::ABox, ω::ABox) = (f.val)(ω.val)
@inline liftapply(::Lift, f, ω::ABox) = f(ω.val)


recurse(p::PwVar{Tuple{T1}}, ω) where {T1} =
  p.f(liftapply(p.args[1], ω))

recurse(p::PwVar{Tuple{T1, T2}}, ω) where {T1, T2} =
  p.f(liftapply(p.args[1], ω), liftapply(p.args[2], ω))

recurse(p::PwVar{<:Tuple}, ω) =
  p.f(map(arg -> liftapply(arg, ω), p.args)...)

# # Notation

# # Collections
# @inline randcollection(xs) = ω -> 32(x -> liftapply(x, ω), xs)
# struct LiftConst end
# const ₚ = LiftConst()
# Base.:*(xs, ::LiftConst) = randcollection(xs)

# end