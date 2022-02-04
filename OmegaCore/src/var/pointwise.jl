# module Pointwise

export pw, l, ₚ, PwVar, liftapply
 
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
x = 1 ~ StdUniform{Float64}()
y = pw(+, x, 4)

flip(ω::Ω) = x(ω) > 0.5

f(ω::Ω) = flip(ω) ? sqrt : sin
randsample(pw(map, f, [0, 1, 2]))
randsample(pw(map, sqrt, [0, 1, 2])) # Will error!
randsample(pw(map, dl(sqrt), [0, 1, 2]))
randsample(pw(f, 3))

g(ϵ) = ω::Ω -> x(ω) + ϵ
u = 1 ~ StdNormal{Float64}()
g.(u) := ω::Ω -> g(u(ω))(ω)

g(ϵ) = (i, ω::Ω) -> i ~ Normal(ω, 0, 1) + ϵ
u = 1 ~ StdNormal{Float64}()
g.(u) := (i, ω::Ω) -> g(u(ω))(i, ω) # This is what I'd want, and the result should be a class, but i cant tell that based on
# Types of u or types of g (well, in principle I could for type of g but not in Julia)


```
"""
# 1. f(::AbstractVariableOrClass, ω) = ...
# 2. Different types, so we decide when we construct them

struct PwClass{ARGS, D} <: AbstractClass
  f::D
  args::ARGS
  PwClass(f::F, args::A) where {F, A} = new{A, F}(f, args)
  PwClass(f::Type{T}, args::A) where {T, A} = new{A, Type{T}}(f, args)
end

# Class lifting
(p::PwClass{Tuple{T1}})(i, ω) where {T1} =
  lift_output(p.f(liftapply(p.args[1], i, ω)), i, ω)

struct PwVar{ARGS, D} <: AbstractVariable
  f::D
  args::ARGS
  PwVar(f::F, args::A) where {F, A} = new{A, F}(f, args)
  PwVar(f::Type{T}, args::A) where {T, A} = new{A, Type{T}}(f, args)
end

pw(f) = (args...) -> PwVar(f, args)
pw(f, arg, args...) = PwVar(f, (arg, args...)) ## Perhaps do the logic here and have the appropriate result

pw(f::F, arg1::A1) where {F, A1} = handle(f, traitvartype(F), arg1, traitvartype(A1))
pw(f::F, arg1::A1, arg2::A2) where {F, A1, A2} = handle(f, traitvartype(F), arg1, traitvartype(A1), arg2, traitvartype(A2))

# Logic, if any of args is a variable its a variable,  If any are class its a class
handle(f, ::TraitIsVariable, arg1, ::TraitIsVariable, arg2, ::TraitIsVariable) = PwVar(f, (arg1, arg2))
handle(f, arg1, ::TraitIsClass, arg2, ::TraitIsVariable) = PwClass(f, (arg1, arg2))

Base.show(io::IO, p::Union{PwVar, PwClass}) = print(io, p.f, "ₚ", p.args)

# Lifting
struct LiftBox{T}# <: ABox
  val::T
end
"`l(x)` constructs object that indicates that `x` should be applied pointwise.  See `pw`"
l(x) = LiftBox(x)

@inline unbox(x::LiftBox) = x.val
@inline unbox(x) = x

@inline liftapply(f::T, ω) where T = liftapply(traitvartype(T), f, ω)
@inline liftapply(f::T, i, ω) where T = liftapply(traitvartype(T), f, i, ω)

@inline liftapply(f::Ref, ω) = f[]
@inline liftapply(f::Ref, i, ω) = f[]

@inline liftapply(f::LiftBox, i, ω) = liftapply(unbox(f), i, ω)

@inline liftapply(::TraitIsVariable, f, ω) = f(ω)
@inline liftapply(::TraitIsClass, f, i, ω) = f(i, ω)
@inline liftapply(::TraitUnknownVariableType, f, i, ω) = f


# Class rules
# rv ⊕ class = (ω. i) -> rv(ω) ⊕ class(i, ω)

"Handle output"
@inline lift_output(op::O, ω) where {O} = lift_output(traitvartype(O), op, ω)
@inline lift_output(::TraitUnknownVariableType, op, ω) = op
@inline lift_output(::TraitIsVariable, op, ω) = op(ω)

recurse(p::PwVar{Tuple{T1}}, ω) where {T1} =
  lift_output(p.f(liftapply(p.args[1], ω)), ω)

recurse(p::PwVar{Tuple{T1, T2}}, ω) where {T1, T2} =
  lift_output(p.f(liftapply(p.args[1], ω), liftapply(p.args[2], ω)), ω)

recurse(p::PwVar{<:Tuple}, ω) =
  lift_output(p.f(map(arg -> liftapply(arg, ω), p.args)...), ω)


## Broadcasting
struct PointwiseStyle <: Broadcast.BroadcastStyle end
Base.BroadcastStyle(::Type{<:AbstractVariable}) = PointwiseStyle()
Base.broadcastable(x::AbstractVariable) = x
Base.broadcasted(::PointwiseStyle, f, args...)  = pw(f, args...)
Base.BroadcastStyle(::PointwiseStyle, ::Base.Broadcast.DefaultArrayStyle{0}) = PointwiseStyle()
