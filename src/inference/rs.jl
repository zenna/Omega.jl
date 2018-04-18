"Rejection Sampling"
abstract type RejectionSample <: Algorithm end

"Sample from `x | y == true` with rejection sampling"
function Base.rand(x::RandVar, y::RandVar{Bool}, alg::Type{RejectionSample};
                   OmegaT=DefOmega)
  while true
    ω = OmegaT()
    yw = y(ω).epsilon
    if Bool(round(yw))
      return x(ω)
    end
  end
end
