module Syntax

using ..OmegaCore.Util: mapf
using ..OmegaCore.Var: pw, liftapply
export @joint, @~, @uid

"Reduces to `@uid ~ expr`"
macro ~(ex)
  esc(:(~(@uid, ($ex))))
end

"autotomatically generated id"
macro uid()
  rand(Int)
end

"""
Random variable over named tuple using varnames as keys

`@joint randvar1 randvar2 ...`

```julia
using OmegaCore
a = 1 ~ StdNormal()
b = 2 ~ StdNormal()
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


end