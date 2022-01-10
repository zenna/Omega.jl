module Rand
using Base: AbstractFloat
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
using Omega, Test
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

# ## Primitives 
# @inline a(id, ::typeof(rand), ω, ::Type{X}) where {X<:AbstractFloat} = StdUniform{X}()(id, ω)
# @inline a(id, ::typeof(rand), ω, ::Type{T<:Integer}) where {T<:Integer} =
#   UniformInt{X}()(id, ω)
# @inline a(id, ::typeof(randn), ω, ::Type{X}) where {X} = StdNormal{X}()(id, ω)

# # zt: Ideally we'd just write this as a post-hook
# @inline traitrand(::trait(RandMutate), randf, ω, args...) =
#   let x = a(counter(ω), randf, ω, args...)
#     inc_counter!(ω)
#     x
#   end

# Base.rand(ω::AbstractΩ, args...) = traitrand(traits(ω), rand, ω, args...)
# Base.randn(ω::AbstractΩ, args...) = traitrand(traits(ω), rand, ω, args...)

inc!(v, ω) = (inc_counter!(ω); v)

Base.rand(ω::AbstractΩ, ::Type{T}) where {T <: AbstractFloat} = inc!(StdUniform{T}()(counter(ω), ω), ω)
Base.randn(ω::AbstractΩ, ::Type{T}) where {T <: AbstractFloat} = inc!(StdNormal{T}()(counter(ω), ω), ω)
Base.rand(ω::AbstractΩ, ::Type{T}) where {T <: Integer} = inc!(UniformInt{T}()(counter(ω), ω), ω)


# Var.posthook(::trait(RandMutate), rand, ω, args...) =
#   inc_counter!(ω)

# Random.randexp
# Random.randperm
# Random.randstring
# Random.randsubseq
# Random.randcycle

end