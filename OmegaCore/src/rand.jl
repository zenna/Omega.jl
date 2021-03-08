module Rand
using ..Util: Box
using ..Tagging
using ..Traits
using ..Space: AbstractΩ
using ..Var

export rv

tagrand(ω, i = Int(0)) = 
  tag(ω, (randmutate = Box(i),))

"""
`rv(x)`

# Inputs
- `x` - function `x(rng::AbstractRNG)` which internally uses `rand(rng, args...)`

# Returns
Random variable

```
using Omega, Distributions, Test
function f(rng)
  a = rand(rng)
  b = rand(rng)
  c = randn(rng)
  a + b + c
end

ω = defω()
a = rv(f)
a1 = a(ω)
a2 = a(ω)
@test a1 == a2
```
"""
rv(x) = ω -> x(tagrand(ω))

# Increment counter
@inline inc_counter!(ω) = ω.tags.randmutate.val += Int(1)
@inline counter(ω) = ω.tags.randmutate.val

@inline a(id, ::typeof(rand), ω, ::Type{X} = Float64) where {X} = StdUniform{X}()(id, ω)
@inline a(id, ::typeof(randn), ω, ::Type{X} = Float64) where {X} = StdNormal{X}()(id, ω)

@inline wow(::trait(RandMutate), randf, ω, args...) =
  let x = a(counter(ω), randf, ω, args...)
    inc_counter!(ω)
    x
  end

Base.rand(ω::AbstractΩ, args...) = wow(traits(ω), rand, ω, args...)
Base.randn(ω::AbstractΩ, args...) = wow(traits(ω), rand, ω, args...)

# Random.randexp
# Random.randperm
# Random.randstring
# Random.randsubseq
# Random.randcycle

end