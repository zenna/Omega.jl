using Omega
using OmegaTestModels
import ForwardDiff
using Flux

const ΩTs = [LinearΩ{Vector{Int}, UnitRange{Int64}, Vector{Float64}},
             Omega.SimpleΩ{Vector{Int}, Float64},
             LinearΩ{Vector{Int}, UnitRange{Int64}, TrackedArray{Float64, 1, Array{Float64,1}}}]

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
end

testgrad(LinearΩ{Vector{Int}, UnitRange{Int64}, Vector{Float64}})

# Test them all
istracked(::Type{LinearΩ{I, SEG, T}}) where {I, SEG, T <: TrackedArray} = true
istracked(ΩT) = false

function testgrad2(; modelcond, ΩT, gradalg)
  @show ΩT  
  println()
  Omega.lineargradient(logerr(modelcond), ΩT(), gradalg)
end

# Filter to differentiable models
models = filter(hascond ∧ isdiff, allmodels)

# Dont use FluxGrad on wrong Omegas, etc
f1(m, ΩT, gradalg) = gradalg == Omega.FluxGrad ?  istracked(ΩT) : true
f2(m, ΩT, gradalg) = gradalg == Omega.ForwardDiffGrad ? !istracked(ΩT) : true

function runtests()
  for model in models, gradalg in gradalgs, ΩT in ΩTs
    if f1(model, ΩT, gradalg) && f2(model, ΩT, gradalg)
      @show model.name
      @show ΩT
      @show gradalg  
      testgrad2(; modelcond = model.cond, ΩT = ΩT, gradalg = gradalg)
    end
  end
end

runtests()