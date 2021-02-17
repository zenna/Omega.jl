The following code is a minimal implementation of Omega.


```
module MiniOmega
using Random

mutable struct Ω <: Random.AbstractRNG
  data::Dict{Int, Any}
  i::Int
end

Ω() = Ω(Dict(), 0)

function Base.rand(w::Ω, args...)
  w.i += 1
  get!(w.data, w.i, rand(Random.GLOBAL_RNG, args...))
end

Base.rand(w::Ω, args...) = (w.i += 1; get!(w.data, w.i, rand(args...)))
Base.rand(w::Ω, dims::Vararg{Integer,N} where N) = (w.i += 1; get!(w.data, w.i, rand(dims)))

struct RandVar
  f::Function
end

(rv::RandVar)(w::Ω) = (w.i = 0; rv.f(w))

Base.rand(x::RandVar) = x(Ω())

cond(x::RandVar, y::RandVar) = RandVar(rng -> y(rng) ? x(rng) : error())

"Rejetion Sampling"
Base.rand(x::RandVar) = try x(Ω()) catch; rand(x) end

export RandVar, Ω
end
```


```
## Example
using Main.MiniOmega
x_(rng) = rand(rng)
x = RandVar(x_)
ω = Ω()
x(ω)
```