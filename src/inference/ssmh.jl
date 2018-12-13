struct SSMHAlg <: Algorithm end
"Single Site Metropolis Hastings"
const SSMH = SSMHAlg()

struct SSMHDriftAlg <: Algorithm end
"Single Site Metropolis Hastings with drift"
const SSMHDrift = SSMHDriftAlg()
defΩ(::SSMHDriftAlg) = SimpleΩ{Vector{Int}, Float64}

defcb(::Union{SSMHAlg, SSMHDriftAlg}) = default_cbs()

# function resample!(sω::SO, tomodify, proposal)  where {SO <: SimpleΩ}
#   elements = map(sω.vals |> keys |> enumerate) do (i,k)
#     val = if i == tomodify
#       (sω.vals[k] |> transform) + noiseσ*randn() |> inv_transform
#     else
#       sω.vals[k]
#     end
#     k => val
#   end
#   elements |> Dict |> SO
# end

normalkernel(x, σ = 0.1) = inv_transform(transform(x) + σ * randn())
normalkernel(x::Array, σ = 0.1) = normalkernel.(x, σ)

function Base.rand(x::RandVar,
                   n::Integer,
                   alg::SSMHAlg,
                   ΩT::Type{OT};
                   proposal = normalkernel,
                   cb = donothing) where {OT <: Ω}
  ω = ΩT()
  xω, sb = applytrackerr(x, ω)
  plast = logerr(sb)
  qlast = 1.0
  samples = [] #FIXME: Type
  accepted = 0
  for i = 1:n
    ω_ = if isempty(ω)
      ω
    else
      resample!(ω, randunifkey(ω), proposal)
    end
    xω_, sb = applytrackerr(x, ω_)
    p_ = logerr(sb)
    ratio = p_ - plast
    if log(rand()) < ratio
      ω = ω_
      plast = p_
      accepted += 1
      xω = xω_
    end
    push!(samples, xω)
    cb((ω = ω, accepted = accepted, p = plast, i = i), IterEnd)
  end
  samples
end

function x()
  x = normal(0.0, 1.0, (3,))
  rand(x, sum(x) ==ₛ 0.0, 100; alg = SSMH)
end