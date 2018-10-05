"Element type of a random variable"
function elemtype(x::RandVar)
  Base.promote_op(apl, typeof(x), Omega.defΩ())
end
@spec rand(x) isa _res