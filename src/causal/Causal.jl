module Causal

using Spec
using DocStringExtensions
using Cassette
using ..Space
import ..Omega
using ..Omega: RandVar, constant, proj
import ..Omega: apl, ppapl, id, params, ciid
using Callbacks: donothing

include("replace.jl")
include("counterfactual.jl")
include("causes.jl")

export replace,
       cf,
       iscausebf
end