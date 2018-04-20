import ForwardDiff

"Gradient ∇Y()"
function gradient(Y::RandVar{Bool}, ω::Omega, vals = linearize(ω))
  Y(ω)
  unpackcall(xs) = Y(unlinearize(xs, ω)).epsilon
  ForwardDiff.gradient(unpackcall, vals)
end