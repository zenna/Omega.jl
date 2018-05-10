"Single Site MH"
abstract type SSMH <: Algorithm end

function update_random(sω::SimpleOmega)
  k = rand(1:length(sω))
  filtered = Iterators.filter(sω.vals |> keys |> enumerate) do x
    x[1] != k end
  SimpleOmega(Dict(k => sω.vals[k] for (i, k) in filtered))
end

"Sample from `x | y == true` with Single Site Metropolis Hasting"
function Base.rand(OmegaT::Type{OT}, y::RandVar, alg::Type{SSMH};
                   n::Integer = 1000,
                   cb = default_cbs(n)) where {OT <: Omega}
  cb = runall(cb)
  ω = OmegaT()
  plast = y(ω) |> logepsilon
  qlast = 1.0
  samples = []
  accepted = 1
  for i = 1:n
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
      accepted += 1
    end
    push!(samples, ω)
    cb(RunData(ω, accepted, p_, i))
  end
  samples
end