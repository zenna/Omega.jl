"Element type of a random variable"
function elemtype(x::RandVar)
  Base.return_types(apl, (typeof(x), Omega.defΩ()))[1]
end
@spec rand(x) isa _res