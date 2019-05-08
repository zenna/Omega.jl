using Zygote
struct ZygoteGradAlg <: GradAlg end
const ZygoteGrad = ZygoteGradAlg()
import ..Omega
Zygote.@nograd Omega.Space.increment

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

function test()
  x = normal(0, 1, (10,))
  y = sum(x)
  lineargradient(y, defΩ()(), ZygoteGrad)
end