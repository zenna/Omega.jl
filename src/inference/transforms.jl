"ω ∉ [0, 1]"
notunit(ω) = ω > 1.0 || ω < 0.0

function clip(x, eps = 1e-5)
  if x == 0.0
    eps
  elseif x == 1.0
    1 - eps
  else
    x
  end
end
@spec 0.0 < res < 1.0

"Bijective transformation from [0, 1] to the real line, T(x)=log(1/(1-x)-1)"
transform(x) = log(clip(x) / (1 - clip(x)))

"The inverse of the transformation above, T^(-1)(y)=1-1/(1+e^y)"
inv_transform(y) = 1 / (1 + exp(-y))

"Jacobian of the transformation above, J(x) = 1/x(1-x)"
jacobian(x) = inv_transform(x) * (1. -inv_transform(x))

"Bijective transformation from [0, 1] to the real line, T(x)=log(1/(1-x)-1)"
unbound(x) = log(clip(x)/(1-clip(x)))

"The inverse of the transformation above, T^(-1)(y)=1-1/(1+e^y)"
bound(y) = 1 / (1 + exp(-y))

"Jacobian of the transformation above, J(x) = 1/x(1-x)"
jac(x) = bound(x) * (1 - bound(x))