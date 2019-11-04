import Zygote
struct ZygoteGradAlg <: GradAlg end
const ZygoteGrad = ZygoteGradAlg()
import ..Omega
Zygote.@nograd Omega.Space.increment
Zygote.@nograd Base.append!

function gradmap(rv, ω::Ω)
  l = apl(rv, ω)
  params = Params(values(ω)) # We can avoid doing this every time.
  g = gradient(params) do
    rv(ω)
  end
  g
end

function lineargradient(rv, ω, ::ZygoteGradAlg)
  Zygote.gradient(ωvec -> apl(rv, unlinearize(ωvec, ω)), linearize(ω))
end

function grad(rv, ω, v, ::ZygoteGradAlg)
  grads = Zygote.gradient(Zygote.Params(v)) do
    rv(ω)
  end
end

grad(rv, ω, ::ZygoteGradAlg) = grad(rv, ω, values(ω), ZygoteGrad)

function gradarray(rv, ω, ::ZygoteGradAlg)
  vs = values(ω)
  grads_ = grad(rv, ω, vs, ZygoteGrad)
  map(v -> grads_[v], vs)
end