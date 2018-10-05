module Causal

using Spec
using ..Space
using ..Omega: RandVar, constant, proj
import ..Omega: apl, ppapl, id, params

include("replace.jl")
include("causes.jl")

export replace
end