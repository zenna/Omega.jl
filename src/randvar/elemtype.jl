"""$(SIGNATURES) Element type of a `rv::RandVar`

The element type of a RandVar is the type of value you get when you sample from it.
from it.  Since `RandVar`s are normal julia functions, this may not be a single concrete type.

Warning.  `elemtype` relies on Julia's type inference.
We use it mostly only for printing and debugging.
Relying on it as part of an algorithm is inadvisable.
"""
function elemtype(rv::RandVar, ΩT::Type{OT} = Omega.defΩ()) where OT
  Base.promote_op(apl, typeof(rv), OT)
end
@spec rand(rv) isa _res