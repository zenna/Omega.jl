"Minimal Probabilistic Programming Langauge"
module Expect

using Distributions

include("soft.jl")
include("omega.jl")
include("randvar.jl")
include("cond.jl")

# include("lift.jl")

export expectation,
       normal,
       uniform,
       Interval,
       curry,
       softeq
end