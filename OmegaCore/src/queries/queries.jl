# Templates of causal queries
module Queries

using ..Conditioning: cnd, |ᶜ, ConditionException, condf
using ..Interventions: intervene, Intervention, AbstractIntervention, |ᵈ

include("basic.jl")
include("counterfactuals.jl")
include("effects.jl")

end