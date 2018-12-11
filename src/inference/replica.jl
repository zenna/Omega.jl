"Replica Exchange (Parallel Tempering)"
struct ReplicaAlg{T <: Algorithm} end

"Sample from `x` using Replica Exchange"
function Base.rand(x::RandVar,
                   n::Integer,
                   alg::ReplicaAlg,
                   ΩT::Type{OT};
                   nreplicas = 2,
                   temps = sort([rand() for i = 1:nreplicas]),
                   cb = donothing) where {OT <: Ω}
  ## Run n in parallel?
  ## When do you swap?
  ## Presumably swapping Omega
  ω = ΩT()
  xω, sb = applytrackerr(x, ω)
  plast = logerr(sb)
  qlast = 1.0
  samples = []
  accepted = 0
  for i = 1:n
    ω_ = if isempty(ω)
      ω
    else
      update_random(ω)
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