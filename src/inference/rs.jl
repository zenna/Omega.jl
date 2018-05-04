"Rejection Sampling"
abstract type RejectionSample <: Algorithm end

"Sample from `x | y == true` with rejection sampling"
function Base.rand(OmegaT::OT, y::RandVar{Bool}, alg::Type{RejectionSample}; n=100) where OT
  samples = OmegaT[]
  p = Progress(n, 1)
  while true
    ω = OmegaT()
    yw = y(ω).epsilon
    if Bool(round(yw))
      push!(samples, ω)
      ProgressMeter.next!(p)
    end
  end
  samples
end

"Sample from `x | y == true` with Metropolis Hasting"
function Base.rand(x::Union{RandVar, UTuple{RandVar}}, y::RandVar{Bool}, alg::Type{RejectionSample};
                   n::Integer = 1000, OmegaT::OT = DefaultOmega) where {OT}
  map(x, rand(OmegaT, y, alg, n=n))
end

