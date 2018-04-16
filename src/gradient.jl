using ForwardDiff

 "Gradient ∇Y()"
function gradient(Y::RandVar{Bool}, ω::DiffOmega, vals = tovector(ω))
  # Y(ω)
  unpackcall(xs) = Y(todiffomega(xs, ω)).epsilon
  ForwardDiff.gradient(unpackcall, vals)
end