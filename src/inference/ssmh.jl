"Single Site Metropolis Hastings"
struct SSMHAlg <: Algorithm end

"Single Site Metropolis Hastings"
const SSMH = SSMHAlg()
defcb(::SSMHAlg) = default_cbs()

isapproximate(::SSMHAlg) = true

function update_random(sω::SO)  where {SO <: SimpleΩ}
  k = rand(1:length(sω))
  filtered = Iterators.filter(sω.vals |> keys |> enumerate) do x
    x[1] != k end
  SO(Dict(k => sω.vals[k] for (i, k) in filtered))
end

"Sample from `x | y == true` with Single Site Metropolis Hasting"
function Base.rand(x::RandVar,
                   n::Integer,
                   alg::SSMHAlg,
                   ΩT::Type{OT};
                   cb = donothing,
                   hack = true) where {OT <: Ω}
  ω = ΩT()
  xω, sb = trackerrorapply(x, ω)
  plast = logepsilon(sb)
  qlast = 1.0
  samples = []
  accepted = 0
  for i = 1:n
    ω_ = if isempty(ω)
      ω
    else
      update_random(ω)
    end
    xω_, sb = trackerrorapply(x, ω_)
    p_ = logepsilon(sb)
    ratio = p_ - plast
    if log(rand()) < ratio
      ω = ω_
      plast = p_
      accepted += 1
      xω = xω_
    end
    push!(samples, xω)
    cb((ω = ω, sample = xω, accepted = accepted, p = plast, i = i), Outside)
  end
  [samples...]
end