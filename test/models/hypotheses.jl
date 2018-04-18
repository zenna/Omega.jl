using Mu
using Distributions

"Generate a randoom argument"
function randargs(rng, sym, weight)
  args = []
  for i = 1:2
    if rand(rng[@id]) > weight
      push!(args, rand(rng[@id][i], 1:20))
    else
      push!(args, randexpr_(rng[@id][i], weight * weight))
    end
  end
  args
end

"Generate a random experiment"
function randexpr_(rng::AbstractRNG, weight = 0.5)
  primitives = [:+, :-, :*, :/]
  head = rand(rng[@id], primitives)
  args = randargs(rng[@id], head, weight)
  Expr(:call, head, args...)
end

randexpr = iid(randexpr_)
evalexpr_(rng) = eval(randexpr(rng))
evalexpr = iid(evalexpr_)

exprs = rand(randexpr, evalexpr == 5.0;
             OmegaT = Mu.SimpleOmega{Mu.Paired, Mu.ValueTuple})
