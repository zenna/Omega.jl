"Conditioning"
module Cond
export cond, condf, condp, |ₚ
using ..Omega
using DocStringExtensions

export observe

include("pred.jl")        # Conditioning on general predicates
include("observe.jl")     # Condtion on observations
include("sugar.jl")       # Syntactic sugar

end
