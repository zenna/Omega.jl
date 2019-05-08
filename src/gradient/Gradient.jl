module Gradient

import Flux
import Zygote
import ForwardDiff
using ..Omega: RandVar, Ω, SimpleΩ, linearize, unlinearize, apl

export gradient, lineargradient, back!, GradAlg, FluxGrad, ForwardDiffGrad, ZygoteGrad

abstract type GradAlg end

"`lineargradient(::RandVar, ω::Ω, ::Alg)` Returns as vector gradient of ω components"
function lineargradient end

"`back!(::RandVar, ω::Ω, ::FluxGradAlg)` update values of ω with gradients"
function back! end

include("old.jl")
include("tracker.jl")
include("forwarddiff.jl")
include("zygote.jl")

end