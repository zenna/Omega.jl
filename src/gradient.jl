# the old

"Gradient ∇Y()"
function gradient(y::RandVar, ω::Ω, vals = linearize(ω))
  # y(ω)
  indomainₛ(y, ω)
  function unpackcall(xs)
    -logerr(indomainₛ(y, unlinearize(xs, ω)))
  end
  ForwardDiff.gradient(unpackcall, vals)
end

function gradient(y::RandVar, sω::SimpleΩ{I, V}, vals) where {I, V <: AbstractArray}
  @assert false
  sω = unlinearize(vals, sω)
  sωtracked = SimpleΩ(Dict(i => param(v) for (i, v) in sω.vals))
  # @grab vals
  l = -err(y(sωtracked))
  # @grab sωtracked
  # @grab y
  # @grab l
  # @assert false
  @assert !(isnan(l))
  Flux.back!(l)
  totalgrad = 0.0
  # @grab sωtracked
  for v in values(sωtracked.vals)
    @assert !(any(isnan(v)))

    @assert !(any(isnan(v.grad)))
    totalgrad += mean(v.grad)
  end
  # @show totalgrad
  sω_ = SimpleΩ(Dict(i => v.data for (i, v) in sωtracked.vals))
  linearize(sω_)
end



"`lineargradient(::RandVar, ω::Ω, ::Alg)` Returns as vector gradient of ω components"
function lineargradient end

"`back!(::RandVar, ω::Ω, ::FluxGradAlg)` update values of ω with gradients"
function back! end

# zt: flux/fd have different signature
# and different return type., difficult to interchange because
# flux just mutates san array while fd returns a value
# flux doesn't assume evaluated 
# fd does

# Flux #
struct FluxGradAlg end
const FluxGrad = FluxGradAlg()

function back!(rv, ω, ::FluxGradAlg)
  l = rv(ω)
  Flux.back!(l)
end

# # FIXME: Remove this
# function gradient(::FluxGradAlg, U, sω::SimpleΩ{I, V}) where {I, V <: AbstractArray}
#   l = U(sω)
#   Flux.back!(l)
# end
# # The New #

lineargradient(rv, ω, ::FluxGradAlg) = (back!(rv, ω, FluxGrad); linearize(ω))

# Forward Diff based # 
struct ForwardDiffGradAlg end
const ForwardDiffGrad = ForwardDiffGradAlg()

function lineargradient(rv, ω::Ω, ::ForwardDiffGradAlg)
  rv(ω) # Init

  # Unlinearizes xs into ω::Ω and applies rv(ω)
  function unlinearizeapl(xs)
    # Replace the tag tag here
    # @assert false
    # zazoom(1)
    # ω_ = tag(ω, dsofttrue(ForwardDiff.Dual))
    # T = ForwardDiff.Dual{Any,Float64,0}
    # rv2 = ciid(ω -> apl(rv, @show(Omega.Soft.tagerror(ω, dsofttrue(T)))))
    # ω_ = Omega.tagerror(ω, dsofttrue(T))
    # then we dont want to override the tag
    # because rv is going to add a tagz
    ωu = unlinearize(xs, ω)
    res = apl(rv, ωu)
    # logerr(res)
    # println(res)
    # res
    # @assert false
  end
  xs = linearize(ω)
  ForwardDiff.gradient(unlinearizeapl, xs)
end

# Zygote #
# struct ZygoteGradAlg end
# const ZygoteGrad = ZygoteGradAlg()

# function gradmap(rv, ω::Ω)
#   l = apl(rv, ω)
#   params = Params(values(ω)) # We can avoid doing this every time.
#   g = gradient(params) do
#     rv(ω)
#   end
#   g
# end

# function lineargradient(rv, ω, ::ZygoteGradAlg)
#   g = gradmap(rv, ω)
#   [gradmap[p] for p in values(ω)]
# end