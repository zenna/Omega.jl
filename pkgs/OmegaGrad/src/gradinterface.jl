
export lineargradient, back!, GradAlg, value, grad

"Gradient Algorithm"
abstract type GradAlg end

"`lineargradient(rv), ω::AbstractΩ, ::GradAlg)` Returns as vector gradient of ω components"
function lineargradient end

"`back!(rv, ω::AbstractΩ, ::GradAlg)` update ω s.t ω[id].grad is gradient"
function back! end

"`grad(rv, ω, ::GradAlg)` returns ω where gradients in components"
function grad end

# "Value associated with dual/tracked/etc number/array"
# function value end