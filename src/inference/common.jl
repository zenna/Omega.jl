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

"Bijective transformation from [0, 1] to the real line, T(x)=log(1/(1-x)-1)"
transform(x) = log.(1./(1.-clip(x)).-1)

"The inverse of the transformation above, T^(-1)(y)=1-1/(1+e^y)"
inv_transform(y) = 1.-1./(1.+exp.(y))

"Jacobian of the transformation above, J(x) = 1/x(1-x)"
jacobian(x) = 1./(x .* (1.-x))

"Bijective transformation from [0, 1] to the real line, T(x)=log(1/(1-x)-1)"
unbound(x) = log(1 / (1 -clip(x)) -1)

"The inverse of the transformation above, T^(-1)(y)=1-1/(1+e^y)"
bound(y) = 1 -1 /(1 + exp(y))

"Jacobian of the transformation above, J(x) = 1/x(1-x)"
jac(x) = 1 / (x * (1 -x))

function showstats(accepted, i, y, ω)
  print_with_color(:light_blue, "acceptance ratio: $(accepted/float(i)) ",
                                "Last log likelihood $(epsilon(y(ω)))\n")
end

function tracecb(::Type{T}) where T
  ωs = T[]
  allωs = Vector{T}[]
  function f(qp, ::Type{Mu.Inside})
    push!(ωs, qp)
  end

  function f(data, ::Type{Mu.Outside})
    push!(allωs, copy(ωs))
    empty!(ωs)
  end
  f, (ωs, allωs)
end
