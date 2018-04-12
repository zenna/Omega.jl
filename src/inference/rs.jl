"Rejection Sampling"
abstract type RejectionSample <: Algorithm end

"Sample from `x | y == true` with rejection sampling"
function Base.rand(x::RandVar, y::RandVar{Bool}, alg::Type{RejectionSample})
  while true
    ω = Omega()
    if y(ω)
      return x(ω)
    end
  end
end
