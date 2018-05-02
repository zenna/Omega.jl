import ForwardDiff

"Gradient ∇Y()"
function gradient(Y::RandVar{Bool}, ω::Omega, vals = linearize(ω))
  Y(ω)
  #@show Y(ω), ω, vals
  unpackcall(xs) = Y(unlinearize(xs, ω)).epsilon
  ForwardDiff.gradient(unpackcall, vals)
  #@show ReverseDiff.gradient(unpackcall, vals)
end
