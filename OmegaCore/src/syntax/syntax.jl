module Syntax

using ..OmegaCore.Util: mapf
using ..OmegaCore.Var: pw, liftapply
import ..OmegaCore: AbstractVariable
export @joint, @~, @uid

"Reduces to `@uid ~ expr`"
macro ~(ex)
  esc(:(~(@uid, ($ex))))
end

macro ~(args...)
  ids = args[1:end-1]
  ex = args[end]
  esc(:(~((@uid, $(ids...)), ($ex))))
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

end