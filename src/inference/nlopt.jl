import NLopt

struct NLoptArgmaxAlg <: OptimAlgorithm end
"NLopt based optimization"
const NLoptArgmax = NLoptArgmaxAlg()
defΩ(::NLoptArgmaxAlg) = LinearΩ{Vector{Int}, UnitRange{Int}, Vector{Float64}}

"NLOpt style loss function (accepting vectors for input/grad) from RandVar `y`"
function nllossfunc(y, ω; usegrad = true)
  i = 1
  function innernllossfunc(ωvec::Vector, grad::Vector)
    ω = unlinearize(ωvec, ω)  # FIXME: Unlinearization requires a structure (inefficient?)
    loss = y(ω)   # 
    if usegrad
      # FIXME: Set the gradient
    end
    lens(Loop, (loss = loss, i = i))
    i += 1
    loss
  end
end

function nlopt(n, lossf; alg = :LN_COBYLA, maximize = true)
  opt = NLopt.Opt(alg, n)
  NLopt.lower_bounds!(opt, 0.0)
  NLopt.upper_bounds!(opt, 1.0)
  if maximize
    NLopt.max_objective!(opt, lossf)
  else
    NLopt.min_objective!(opt, lossf)
  end
  opt
end

"ω which maximizes x(ω) using NLopt" 
function Base.argmax(x::RandVar,
                     alg::NLoptArgmaxAlg,
                     ΩT::Type{OT};
                     nloptargs = ()) where {OT <: Ω}
  # initialize at random point 
  ωinit = ΩT()
  x(ωinit)
  ωinitvec = linearize(ωinit)
  lossf = nllossfunc(x, ωinit)

  #  reate optimization
  n = length(ωinitvec)
  opt = nlopt(n, lossf; nloptargs...)

  # Optimize
  (minf, ωvecoptim, ret) = NLopt.optimize(opt, ωinitvec)
  unlinearize(ωvecoptim, ωinit)
end