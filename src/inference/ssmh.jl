"Single Site MH"
abstract type SSMH <: Algorithm end

function update_random(sω::SimpleOmega)
  k = rand(1:length(sω))
  filtered = Iterators.filter(sω.vals |> keys |> enumerate) do x
    x[1] != k end
  SimpleOmega(Dict(k => sω.vals[k] for (i, k) in filtered))
end

"Sample from `x | y == true` with Single Site Metropolis Hasting"
function Base.rand(OmegaT::Type{OT}, y::RandVar{<:MaybeSoftBool}, alg::Type{SSMH};
                   n::Integer = 1000) where {OT <: Omega}
  ω = OmegaT()
  plast = y(ω) |> logepsilon
  qlast = 1.0
  samples = []
  accepted = 0.0
  @showprogress 1 "Running Chain" for i = 1:n
    ω_ = if isempty(ω)
      ω
    else
      update_random(ω)
    end
    p_ = y(ω_) |> logepsilon
    ratio = p_ - plast
    if log(rand()) < ratio
      ω = ω_
      plast = p_
      accepted += 1.0
    end
    push!(samples, ω)
  end
  print_with_color(:light_blue, "acceptance ratio: $(accepted/float(n))\n")
  samples
end

# "Sample from `x | y == true` with Metropolis Hasting"
# function Base.rand(x::Union{RandVar, UTuple{RandVar}}, y::RandVar{Bool}, alg::Type{SSMH};
#                    n::Integer = 1000, OmegaT::OT = DefaultOmega) where {OT}
#   map(x, rand(OmegaT, y, alg, n=n))
# end

