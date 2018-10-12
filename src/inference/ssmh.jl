"Single Site Metropolis Hastings"
struct SSMHAlg <: Algorithm end

"Single Site Metropolis Hastings"
const SSMH = SSMHAlg()
defcb(::SSMHAlg) = default_cbs()

isapproximate(::SSMHAlg) = true
ismcmc(::SSMHAlg) = true

function update_random(sω::SO)  where {SO <: SimpleΩ}
  k = rand(1:length(sω))
  filtered = Iterators.filter(sω.vals |> keys |> enumerate) do x
    x[1] != k end
  SO(Dict(k => sω.vals[k] for (i, k) in filtered))
end

function innerloop!(x, ω, n, cb, update!)
  accepted = 0
  xω, sb = trackerrorapply(x, ω)
  plast = logepsilon(sb)
  qlast = 1.0
  for i = 1:n # FIXME when n = 1
    update!(xω, ω, i)
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
    cb((ω = ω, sample = xω, accepted = accepted, p = plast, i = i), Outside)
  end
  (xω, ω)
end

"`n` Samples from `x` with Single Site Metropolis Hasting"
function Base.rand(x::RandVar,
                   n::Integer,
                   alg::SSMHAlg,
                   ω::OT;
                   cb = donothing,
                   T = elemtype(x)) where {OT <: Ω}
  xsamples = Array{T}(undef, n)
  update! = let samples = xsamples 
    (xω, ω, i) -> @inbounds xsamples[i] = xω
  end
  innerloop!(x, ω, n, cb, update!)
  xsamples
end

"`n` Samples from `x` with Single Site Metropolis Hasting"
function Base.rand(T::Type{OT},
                   x::RandVar,
                   n::Integer,
                   alg::SSMHAlg,
                   ω::OT;
                   cb = donothing) where {OT <: Ω}
  ωsamples = Array{OT}(undef, n)
  update! = let ωsamples = ωsamples 
    (xω, ω, i) -> @inbounds ωsamples[i] = ω 
  end
  innerloop!(x, ω, n, cb, update!)
  ωsamples
end