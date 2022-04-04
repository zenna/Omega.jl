module Static

using Cassette

export causalgraph, CausalGraph
using Spec

Cassette.@context StaticCtx

@inline tagstatic(ω; cg_ = CausalGraph()) = 
  tag(ω, (static = (cg = cg_, seen = seen)))

struct CausalGraph
end

"Causal Graph of random variable `x`"
function causalgraph(x, ω = defω())
  ω_ = tagstatic(ω)
  x(ω)
  x.cg
end

function Var.

@pre isstatic(x)

function test()
  μ = (1 ~ Normal(0, 1))(ω)
  x = (2 ~ Normal(μ, 1))(ω)
  causalgraph(x)
end

end

end