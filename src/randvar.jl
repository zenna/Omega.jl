abstract type AbstractRandVar{T} end

# "Random Variable `Ω -> T`"
# mutable struct RandVar{T} <: AbstractRandVar{T}
#   f::Function
#   ωids::Set{Int}
# end

struct RandVar{T} <: AbstractRandVar{T}
  f::Function
  args::Tuple
end

function (rv::RandVar)(ω::Omega)
  args = (apl(a, ω) for a in rv.args)
  (rv.f)(args..., ω)
end

function Base.copy(x::RandVar{T}) where T
  RandVar{T}(x.f, x.ωids)
end

"All dimensions of `ω` that `x` draws from"
ωids(x::RandVar) = x.ωids
ωids(x) = Set{Int}() # Non RandVars defaut to emptyset (convenience)

## Functions
## =========
"
Project `y` onto the randomness of `x`*

```jldoctest
p = uniform(0.1, 0.9)
X = Bernoulli(p)
y = normal(x, 1)
[rand(expectation(curry(y, x))) for _ = 1:10]
[rand(expectation(curry(y, p))) for _ = 1:10]
```
"
function curry(x::RandVar{T}, y::RandVar) where T
  RandVar{RandVar{T}}(ω1 -> let ω_ = project(ω1, ωids(y))
                              RandVar{T}(ω2 -> x(merge(ω2, ω_)), ωids(x))
                            end,
                      ωids(x))
end