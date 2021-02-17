module Syntax

using ..OmegaCore.Util: mapf
using ..OmegaCore.Var: pw
using Distributions
export @joint

"""
Random variable over named tuple using varnames as keys

`@joint randvar1 randvar2 ...`

```julia
using Distributions
a = 1 ~ Normal(0, 1)
b = 2 ~ Normal(0, 1)
c = a >=ₚ b
randsample(@joint a b c)
=> (Ashoots = false, Bshoots = false)
```
"""
macro joint(args::Symbol...)
  esc(:(ω -> NamedTuple{$args}(OmegaCore.Util.mapf(ω, tuple($(args...))))))
end

export ==ₚ, >=ₚ, <=ₚ, >ₚ, <ₚ, !ₚ, &ₚ, |ₚ, ifelseₚ, +ₚ, -ₚ, *ₚ, /ₚ
@inline x ==ₚ y = pw(==, x, y)
@inline x >=ₚ y = pw(>=, x, y)
@inline x >ₚ y = pw(>, x, y)
@inline x <ₚ y = pw(<, x, y)
@inline x <=ₚ y = pw(<=, x, y)
@inline x +ₚ y = pw(+, x, y)
@inline x -ₚ y = pw(-, x, y)
@inline x *ₚ y = pw(*, x, y)
@inline x /ₚ y = pw(/, x, y)

@inline x |ₚ y = pw(|, x, y)
@inline x &ₚ y = pw(&, x, y)
@inline !ₚ(x) = pw(!, x)
@inline ifelseₚ(a, b, c) = pw(ifelse, a, b, c)


#FIXme generalize this
# Normalₚ(args...) = pw(Distributions.Normal, args...)
# Uniformₚ(args...) = pw(Distributions.Uniform, args...)
# Gammaₚ(args...) = pw(Distributions.Gamma, args...)
# DiscreteUniformₚ(args...) = pw(Distributions.DiscreteUniform, args...)
# Poissonₚ(args...) = pw(Distributions.Poisson, args...)
# NegativeBinomialₚ(args...) = pw(Distributions.NegativeBinomial, args...)

# export Normalₚ,
#        Uniformₚ,
#        Gammaₚ,
#        DiscreteUniformₚ,
#        Poissonₚ,
#        NegativeBinomialₚ

end