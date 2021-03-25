module Memoize
import ..OmegaCore: Var
using ..Traits: traits, trait
using ..Tagging: Mem, tag
using ..Basis:AbstractΩ
export mem, defcache
# # Memoization

"Default cache"
defcache() = Dict{Any, Any}()

@inline tagmem(ω, cache = defcache()) = tag(ω, (mem = cache,))

# cache traits
cache(f, ω) = true

@inline function memapl(f, ω)
  # @show "hello Samantha"
  if cache(f, ω)
    result = get(ω.tags.mem, f, 0)
    if result === 0
      res = Var.recurse(f, ω)
      ω.tags.mem[f] = res
      return res
    else
      return ω.tags.mem[f]#::(Core.Compiler).return_type(f, typeof((ω,)))
    end
  else
    return Var.recurse(f, ω)
  end
end

@inline Var.dispatch(::trait(Mem), f, ω::AbstractΩ) = memapl(f, ω)

"""
`mem(x)`

A 'memoized' version of `x` such that the result of calls to `x(ω)` are cached.

```julia
using OmegaCore, Distributions, LinearAlgebra, BenchmarkTools
x = dimsnth(Normal(0, 1), (1000, 1000))
h(x) = (println("call!"); svd(x).S)
y(ω) = h(x(ω))
const y_ = Variable(y)
vars(ω) = (y_(ω), y_(ω)*10, y_(ω)*20)
@benchmark vars(ω) setup = (ω = randω())
@benchmark mem(vars)(ω) setup = (ω = randω())
```
"""
@inline mem(f, cache = defcache()) = ω -> f(tagmem(ω, cache))

end