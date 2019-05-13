import ForwardDiff

struct ForwardDiffGradAlg <: GradAlg end
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

value(x::ForwardDiff.Dual) = x.value