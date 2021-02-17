export mem, defcache
# # Memoization

"Default cache"
defcache() = Dict{defID(), Any}()

@inline tagmem(ω, cache = defcache()) = tag(ω, (memoize = cache))

# Don't ache traits
cache(f) = true

@inline function memapl(f, ω)
  if cache(f)
    result = get(ω.tags.cache, f.id, 0)
    if result === 0
      res = recurse(f, ω)
      ω.tags.cache[f.id] = res
      res
    else
      ω.tags.cache[f.id]::(Core.Compiler).return_type(f, typeof((ω,)))
    end
  else
    recurse(f, ω)
  end
end

"""
Memoize a variable.

`mem(x)` returns a 'memoized' version of `x` such that the result of calls to
`x(ω)` are cached.

```julia
using LinearAlgebra, BenchmarkTools
x = normal(0, 1, (1000, 1000))
h(x) = (println("call!"); svd(x).S)
y = lift(h)(x)
vars = randtuple((y, y*10, y*20))
@benchmark vars(ω) setup = (ω = rand(defΩ()))
@benchmark vars(ω) setup = (ω = tagmem(rand(defΩ())))
```
"""
@inline mem(f, cache = defcache()) = ω -> tagmem(ω, V)