### A Pluto.jl notebook ###
# v0.17.1

using Markdown
using InteractiveUtils

# ╔═╡ f573a320-6700-11ec-06d3-9553fe4dd603
begin
    import Pkg
    # activate the shared project environment
    Pkg.activate(Base.current_project())
    using Omega, Distributions, UnicodePlots, FreqTables
end

# ╔═╡ f7c37755-c928-4c52-8091-27bce4bf6dd6
begin
	# Utility functions
	viz(var::Vector{T} where T<:Union{String, Char}) = 	
		barplot(Dict(freqtable(var)))
	viz(var::Vector{<:Real}) = histogram(var, symbols = ["■"])
	viz(var::Vector{Bool}) = viz(string.(var))
	struct UniformDraw{T}
		elem::T
	end
	(u::UniformDraw)(i, ω) = 
		u.elem[(i ~ DiscreteUniform(1, length(u.elem)))(ω)]
end

# ╔═╡ 7c6b8acd-40e2-4eb8-aefc-34fe23f6d46b
md"""
An important worry about Bayesian models of learning is that the Hypothesis space must either be too simple (e.g. a single coin weight!), specified in a rather ad-hoc way, or both. There is a tension here: human representations of the world are enormously complex and so the space of possible representations must be correspondingly big, and yet we would like to understand the representational resources in simple and uniform terms. How can we construct very large (possibly infinite) hypothesis spaces and priors over them? One possibility is to build the hypotheses themselves via stochastic recursion. That is, we build hypotheses by a combination of primitives and combination operations, randomly deciding which to use.

For instance, imagine that we want a model that generates strings, but we want the strings to be valid arithmetic expressions. Since we know that arithmetic has as primitives numbers and combines them with operations, we can define a simple generator:
"""

# ╔═╡ 51327bd3-0c04-48b1-b7db-b6bb5a7ac6b9
random_const = string ∘ UniformDraw(0:9)

# ╔═╡ 63caf0d9-6e91-40e2-8529-af7c2610b67f
function random_combination(f, g, ω, i)
	op = (i ~ UniformDraw(['+', '-', '*', '/', '^']))(ω)
	return string('(', f, op, g, ')')
end

# ╔═╡ e14a2bc6-7b78-40b5-96c1-deaedffb2552
function random_arithmetic_expression(ω, i = 0)
	if (i ~ Bernoulli())(ω)
		e1 = random_arithmetic_expression(ω, (i..., 1))
		e2 = random_arithmetic_expression(ω, (i..., 2))
		return random_combination(e1, e2, ω, i)
	else
		return (i ~ random_const)(ω)
	end
end

# ╔═╡ 34bb61a2-260b-449d-9c41-af8bbd3ad141
randsample(random_arithmetic_expression)

# ╔═╡ 4ec92d6c-56bf-441b-9443-ea59364404c7
md"""
Notice that `random_arithmetic_expression` can generate an infinite set of different strings, but that more complex strings are less likely. That is, the process we use to build strings also (implicitly) defines a prior over strings that penalizes complexity. To see this more let’s sample 100 strings:
"""

# ╔═╡ df6bacaf-ef1b-46c6-b99b-d9ee06debf4d
viz(randsample(random_arithmetic_expression, 100))

# ╔═╡ 11c2c5b9-aee6-4a70-904b-798970398bed
md"""
If we now interpret our strings as hypotheses, we have compactly defined an infinite hypothesis space and its prior.
"""

# ╔═╡ 3c8efb48-d333-4461-ad82-e680ca86163e
md"""
## Inferring an Arithmetic Function
Consider the following program, which induces an arithmetic function from examples. The basic generative process is similar to the above, but we include the identity function (‘x’), making the resulting expression a function of ‘x’. At every step we create a runnable function form and also the previous nice string form.
"""

# ╔═╡ bad6c734-031d-46a4-b66e-fa6fb2abcf9e
plus = (fn = (a, b) -> a + b, expr = '+')

# ╔═╡ 7f17a2de-34fd-45d9-b7f4-3022d9cab2ab
multipy = (fn = (a, b) -> a * b, expr = '*')

# ╔═╡ 27d05d40-c7d6-4074-ae1c-92745d85eeea
divide = (fn = (a, b) -> round(Int64, a/b), expr = '/')

# ╔═╡ 7b161fee-3460-4c55-8bbb-6201b51f67f0
minus = (fn = (a, b) -> a - b, expr = '-')

# ╔═╡ f83e81d1-105f-45b4-8418-b4070918b706
power = (fn = (a, b) -> a ^ b, expr = '^')

# ╔═╡ 1e34bc7b-571b-4e9b-878b-16c8090f96f1
binary_ops = [plus, multipy, divide, minus, power]

# ╔═╡ 9ab44db1-eab7-4f48-9cce-125cd200693f
identity = (fn = x -> x, expr = 'x')

# ╔═╡ 165019d5-d1f3-4984-9ae5-d0f485d14e98
function random_constant_function(i, ω)
	c = (i ~ UniformDraw(0:9))(ω)
	return (fn = x -> c, expr = string(c))
end

# ╔═╡ 8fc92e8d-7e2c-4c34-990f-15f12bd9fd8c
function random_combination_function(f, g, ω, i)
	op = (i ~ UniformDraw(binary_ops))(ω)
	opfn = op.fn
	ffn = f.fn
	gfn = g.fn
	return (fn = x -> opfn(ffn(x), gfn(x)), expr = string(f.expr, op.expr, g.expr))
end

# ╔═╡ 815bbb35-3f87-403e-9db9-099439adaf09
function random_arithmetic_expr_fn(ω, i = 0)
	if (i ~ Bernoulli())(ω)
		e1 = random_arithmetic_expr_fn(ω, (i..., 1))
		e2 = random_arithmetic_expr_fn(ω, (i..., 2))
		return random_combination_function(e1, e2, ω, i)
	else
		return ((@uid, i...) ~ Bernoulli())(ω) ? identity : (i ~ random_constant_function)(ω)
	end
end

# ╔═╡ 64fee368-801f-4024-8d18-e3db22f99fb6
randsample(random_arithmetic_expr_fn)

# ╔═╡ 90294f8f-83ac-4101-84fa-0984467a5cef
function_eval =
	(ω -> random_arithmetic_expr_fn(ω)) |ᶜ ((ω -> random_arithmetic_expr_fn(ω).fn(1)) ==ₚ 3)

# ╔═╡ eff3ce23-e1db-40b9-8aae-8b9520299b36
randsample(function_eval)

# ╔═╡ 9a22ab15-d0fd-4636-99c8-c3cd3f8a03cf
md"""
This model can learn any function consisting of the integers 0 to 9 and the operations add, subtract, multiply, divide, and power. The condition in this case asks for an arithmetic expression on variable `x` such that it evaluates to $3$ when `x` is $1$. There are many extensionally equivalent ways to satisfy the condition, for instance, the expressions `3`, `1 + 2`, and `x + 2`, but because the more complex expressions require more choices to generate, they are chosen less often.

Notice that the model puts the most probability on a function that always returns `3` ($f(x)=3$). This is the simplest hypothesis consistent with the data.

This model learns from an infinite hypothesis space—all expressions made from ‘x’, ‘+’, ‘-‘, and constant integers—but specifies both the hypothesis space and its prior using the simple generative process `random_arithmetic_expr_fn`.

## Example: Rational Rules
How can we account for the productivity of human concepts (the fact that every child learns a remarkable number of different, complex concepts)? The “classical” theory of concepts formation accounted for this productivity by hypothesizing that concepts are represented compositionally, by logical combination of the features of objects (see for example Bruner, Goodnow, and Austin, 1951). That is, concepts could be thought of as rules for classifying objects (in or out of the concept) and concept learning was a process of deducing the correct rule.

While this theory was appealing for many reasons, it failed to account for a variety of categorization experiments.

Some effects (like gradient of generalization, typicality, prototype enhancement) were difficult to capture with classical rule-based models of category learning, which led to deterministic behavior. As a result of such difficulties, psychological models of category learning turned to more uncertain, prototype and exemplar based theories of concept representation. These models were able to predict behavioral data very well, but lacked compositional conceptual structure.

Is it possible to get graded effects from rule-based concepts? Perhaps these effects are driven by uncertainty in learning rather than uncertainty in the representations themselves? To explore these questions Goodman, Tenenbaum, Feldman, and Griffiths (2008) introduced the Rational Rules model, which learns deterministic rules by probabilistic inference. This model has an infinite hypothesis space of rules (represented in propositional logic), which are generated compositionally. Here is a slightly simplified version of the model:
"""

# ╔═╡ 614e4cd8-e24d-4df0-aaa2-1c204fb8667d
num_features = 4

# ╔═╡ 68198da3-48d6-479b-9e36-519d1539bcf5
make_obj(l) = zip(["trait1", "trait2", "trait3", "trait4", "fep"], l)

# ╔═╡ 7083a884-34e1-44cf-b0f3-688ba767294f
feps(l) = map(make_obj(l), [[0,0,0,1, 1], [0,1,0,1, 1], [0,1,0,0, 1], [0,0,1,0, 1], [1,0,0,0, 1]])

# ╔═╡ ea8c704d-4da4-4087-89e1-55d2279f99d6
non_feps(l) = map(make_obj(l), [[0,0,1,1, 0], [1,0,0,1, 0], [1,1,1,0, 0], [1,1,1,1, 0]])

# ╔═╡ f98eb772-a876-401b-af95-aca72bb5878f
others(l) = map(make_obj(l), [[0,1,1,0], [0,1,1,1], [0,0,0,0], [1,1,0,1], [1,0,1,0], [1,1,0,0], [1,0,1,1]])

# ╔═╡ de6690d6-1b96-4a7f-ae1d-e215dc8bcdec
data(l) = vcat(feps(l), non_febs(l))

# ╔═╡ b8f4e7da-7974-4fe7-82a4-35b43f82bd48
all_objects(l) = vcat(others(l), feps(l), non_feps(l))

# ╔═╡ febda52b-f986-46a8-9e1a-7532e79d0a9f
begin
# here are the human results from Nosofsky et al, for comparison:
	human_feps = [.77, .78, .83, .64, .61]
	human_non_feps = [.39, .41, .21, .15]
    human_other = [.56, .41, .82, .40, .32, .53, .20]
    human_data = vcat(human_feps, human_non_feps)
end

# ╔═╡ a8ad83d0-253c-487e-91a5-1439b9ce146b
τ = 0.3

# ╔═╡ a7886471-3b38-4979-83d8-f322d50cd227
noise_param = exp(-1.5)

# ╔═╡ 3561f219-0b68-4458-a21b-57fcacffb85e
# a generative process for disjunctive normal form propositional equations:
function sample_pred(i, ω)
	trait = (i ~ uniformDraw(["trait1", "trait2", "trait3", "trait4"]))(ω)
    value = (i ~ Bernoulli())(ω)
  return x -> (x[trait] == value)
end

# ╔═╡ bd5eadc7-ea22-4867-92c3-ad72b09a9422
var sampleConj = function() {
  if(flip(tau)) {
    var c = sampleConj()
    var p = samplePred()
    return function(x) {return c(x) && p(x)}
  } else {
    return samplePred()
  }
}

# ╔═╡ Cell order:
# ╠═f573a320-6700-11ec-06d3-9553fe4dd603
# ╠═f7c37755-c928-4c52-8091-27bce4bf6dd6
# ╟─7c6b8acd-40e2-4eb8-aefc-34fe23f6d46b
# ╠═51327bd3-0c04-48b1-b7db-b6bb5a7ac6b9
# ╠═63caf0d9-6e91-40e2-8529-af7c2610b67f
# ╠═e14a2bc6-7b78-40b5-96c1-deaedffb2552
# ╠═34bb61a2-260b-449d-9c41-af8bbd3ad141
# ╟─4ec92d6c-56bf-441b-9443-ea59364404c7
# ╠═df6bacaf-ef1b-46c6-b99b-d9ee06debf4d
# ╟─11c2c5b9-aee6-4a70-904b-798970398bed
# ╟─3c8efb48-d333-4461-ad82-e680ca86163e
# ╠═bad6c734-031d-46a4-b66e-fa6fb2abcf9e
# ╠═7f17a2de-34fd-45d9-b7f4-3022d9cab2ab
# ╠═27d05d40-c7d6-4074-ae1c-92745d85eeea
# ╠═7b161fee-3460-4c55-8bbb-6201b51f67f0
# ╠═f83e81d1-105f-45b4-8418-b4070918b706
# ╠═1e34bc7b-571b-4e9b-878b-16c8090f96f1
# ╠═9ab44db1-eab7-4f48-9cce-125cd200693f
# ╠═165019d5-d1f3-4984-9ae5-d0f485d14e98
# ╠═8fc92e8d-7e2c-4c34-990f-15f12bd9fd8c
# ╠═815bbb35-3f87-403e-9db9-099439adaf09
# ╠═64fee368-801f-4024-8d18-e3db22f99fb6
# ╠═90294f8f-83ac-4101-84fa-0984467a5cef
# ╠═eff3ce23-e1db-40b9-8aae-8b9520299b36
# ╟─9a22ab15-d0fd-4636-99c8-c3cd3f8a03cf
# ╠═614e4cd8-e24d-4df0-aaa2-1c204fb8667d
# ╠═68198da3-48d6-479b-9e36-519d1539bcf5
# ╠═7083a884-34e1-44cf-b0f3-688ba767294f
# ╠═ea8c704d-4da4-4087-89e1-55d2279f99d6
# ╠═f98eb772-a876-401b-af95-aca72bb5878f
# ╠═de6690d6-1b96-4a7f-ae1d-e215dc8bcdec
# ╠═b8f4e7da-7974-4fe7-82a4-35b43f82bd48
# ╠═febda52b-f986-46a8-9e1a-7532e79d0a9f
# ╠═a8ad83d0-253c-487e-91a5-1439b9ce146b
# ╠═a7886471-3b38-4979-83d8-f322d50cd227
# ╠═3561f219-0b68-4458-a21b-57fcacffb85e
# ╠═bd5eadc7-ea22-4867-92c3-ad72b09a9422
