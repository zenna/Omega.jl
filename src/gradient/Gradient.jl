module Gradient

using ..Omega: RandVar, Ω, SimpleΩ, linearize, unlinearize, apl

export gradient, lineargradient, back!, GradAlg, value, grad, gradarray

# Gradient interfaces

abstract type GradAlg end

"`lineargradient(::RandVar, ω::Ω, ::Alg)` Returns as vector gradient of ω components"
function lineargradient end

"`back!(::RandVar, ω::Ω, ::TrackerGradAlg)` update values of ω with gradients"
function back! end

"`grad(rv, ω)` returns ω where gradients in components"
function grad end

"Value associated with dual/tracked/etc number/array"
function value end

# Default behaviour is identiy
value(x) = x

# AD implementations

include("old.jl") # Delete me!

include("tracker.jl")
export TrackerGrad

include("forwarddiff.jl")
export ForwardDiffGrad

include("zygote.jl")
export ZygoteGrad

end