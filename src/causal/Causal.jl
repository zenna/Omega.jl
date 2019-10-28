module Causal

using Spec
using DocStringExtensions
using Cassette
using Callbacks: donothing

using ..Space
import ..Omega
using ..IDS: ID
using ..NonDet: RandVar, constant, proj
import ..NonDet: apl, ppapl, id, params, ciid, uid

include("replace.jl")
include("counterfactual.jl")
include("causes.jl")

export replace,
       cf,
       iscausebf
end