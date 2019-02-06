module TestNamespace

using Omega
using TestModels
import ForwardDiff

# Add to test, more complex models,
# Different Om typ

const ΩTs = [LinearΩ{Vector{Int}, UnitRange{Int64}, Vector{Float64}},
             Omega.SimpleΩ{Vector{Int}, Float64}]

const gradalgs = [Omega.FluxGrad,
                  Omega.ForwardDiffGrad,
                  # Omega.ZygoteGrad
                  ]

function testgrad(OT = Omega.SimpleΩ{Vector{Int}, Float64})
  μ = uniform(0.0, 1.0)
  x = normal(μ, 1.0) + normal(μ, 1.0)
  y = logerr(x ==ₛ 1.0)
  ω = OT()
  y(ω)
  Omega.lineargradient(y, ω, Omega.ForwardDiffGrad)
  Omega.lineargradient(y, ω, Omega.ForwardDiffGrad)
end

testgrad(LinearΩ{Vector{Int}, UnitRange{Int64}, Vector{Float64}})

function testgrad2(; modelcond, ΩT, gradalg)
  Omega.lineargradient(modelcond, ΩT(), gradalg)
end

models = filter(allmodels, hascond & isdiff)

for model in models, gradalg in gradalgs, ΩT in ΩTs
  testgrad(;modelcond = model().cond, ΩT = ΩT, gradalg = gradalg)
end


# function testgrad2()
#   μ = normal(0.0, 1.0)
#   x = normal(μ, 1.0)
#   samples = y = x ==ₛ 3.0

#   # Gradient test
#   ω = Omega.SimpleΩ{Vector{Int}, Float64}()
#   y(ω)
#   unpackcall(xs) = Omega.err(y(Omega.unlinearize(xs, ω)))
#   Omega.gradient(y, ω)
#   ForwardDiff.gradient(unpackcall, [.3, .2])
# end

# testgrad2()

end