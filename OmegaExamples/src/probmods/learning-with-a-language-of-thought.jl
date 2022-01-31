### A Pluto.jl notebook ###
# v0.17.1

using Markdown
using InteractiveUtils

# ╔═╡ f573a320-6700-11ec-06d3-9553fe4dd603
begin
    import Pkg
    # activate the shared project environment
    Pkg.activate(Base.current_project())
    using Omega, Distributions, UnicodePlots, OmegaExamples
	using Images, Plots
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
If we now interpret our strings as _hypotheses_, we have compactly defined an infinite hypothesis space and its prior.
"""

# ╔═╡ 3c8efb48-d333-4461-ad82-e680ca86163e
md"""
## Inferring an Arithmetic Function
Consider the following program, which induces an arithmetic function from examples. The basic form is the same as the above example but to evaluate the expression we use `eval(Meta.parse(x))` where `x` is the expression in string form.
"""

# ╔═╡ 90294f8f-83ac-4101-84fa-0984467a5cef
function_eval =
	random_arithmetic_expression |ᶜ (eval ∘ Meta.parse ∘ random_arithmetic_expression ==ₚ 3)

# ╔═╡ eff3ce23-e1db-40b9-8aae-8b9520299b36
randsample(function_eval, 100, alg = MH)

# ╔═╡ 9a22ab15-d0fd-4636-99c8-c3cd3f8a03cf
md"""
This model can learn any function consisting of the integers $0$ to $9$ and the operations add, subtract, multiply, divide, and power. The condition, in this case, asks for an arithmetic expression such that it evaluates to $3$. There are many extensionally equivalent ways to satisfy the condition, for instance, the expressions `3`, `1 + 2`, but because the more complex expressions require more choices to generate, they are chosen less often.

Notice that the model puts the most probability on a function that always returns `3`. This is the simplest hypothesis consistent with the data.

## Example: Rational Rules
How can we account for the productivity of human concepts (the fact that every child learns a remarkable number of different, complex concepts)? The “classical” theory of concepts formation accounted for this productivity by hypothesizing that concepts are represented compositionally, by logical combination of the features of objects (see for example Bruner, Goodnow, and Austin, 1951). That is, concepts could be thought of as rules for classifying objects (in or out of the concept) and concept learning was a process of deducing the correct rule.

While this theory was appealing for many reasons, it failed to account for a variety of categorization experiments. Here are the training examples, and one transfer example, from the classic experiment of Medin and Schaffer (1978). The bar graph above the stimuli shows the portion of human participants who said that bug was a “fep” in the test phase (the data comes from a replication by Nosofsky, Gluck, Palmeri, McKinley (1994); the bug stimuli are courtesy of Pat Shafto):
"""

# ╔═╡ 3dbd9ef4-f995-4aa3-b939-5baf36225f05
plot(load("images/fep.png"))

# ╔═╡ 17bba76a-c480-4186-b42d-9eb4b26c7a53
md"""
Notice three effects: there is a gradient of generalization (rather than all-or-nothing classification), some of the Feps are better (or more typical) than others (this is called “typicality”), and the transfer item is a ‘‘better’’ Fep than any of the Fep exemplars (this is called “prototype enhancement”). Effects like these were difficult to capture with classical rule-based models of category learning, which led to deterministic behavior. As a result of such difficulties, psychological models of category learning turned to more uncertain, prototype and exemplar based theories of concept representation. These models were able to predict behavioral data very well, but lacked compositional conceptual structure.

Is it possible to get graded effects from rule-based concepts? Perhaps these effects are driven by uncertainty in _learning_ rather than uncertainty in the representations themselves? To explore these questions Goodman, Tenenbaum, Feldman, and Griffiths (2008) introduced the Rational Rules model, which learns deterministic rules by probabilistic inference. This model has an infinite hypothesis space of rules (represented in propositional logic), which are generated compositionally. Here is a slightly simplified version of the model, applied to the above experiment:
"""

# ╔═╡ 614e4cd8-e24d-4df0-aaa2-1c204fb8667d
num_features = 4

# ╔═╡ 68198da3-48d6-479b-9e36-519d1539bcf5
make_obj(l) = NamedTuple(Dict(zip([:trait1, :trait2, :trait3, :trait4, :fep], l)))

# ╔═╡ 7083a884-34e1-44cf-b0f3-688ba767294f
feps = map(make_obj, 
	[   [0, 0, 0, 1, 1], 
		[0, 1, 0, 1, 1], 
		[0, 1, 0, 0, 1], 
		[0, 0, 1, 0, 1], 
		[1, 0, 0, 0, 1] 
	])

# ╔═╡ ea8c704d-4da4-4087-89e1-55d2279f99d6
non_feps = map(make_obj, 
	[   [0, 0, 1, 1, 0], 
		[1, 0, 0, 1, 0], 
		[1, 1, 1, 0, 0], 
		[1, 1, 1, 1, 0]
	])

# ╔═╡ f98eb772-a876-401b-af95-aca72bb5878f
others = map(make_obj, 
	[   [0, 1, 1, 0], 
		[0, 1, 1, 1], 
		[0, 0, 0, 0], 
		[1, 1, 0, 1], 
		[1, 0, 1, 0], 
		[1, 1, 0, 0], 
		[1, 0, 1, 1]
	])

# ╔═╡ de6690d6-1b96-4a7f-ae1d-e215dc8bcdec
data = vcat(feps, non_feps)

# ╔═╡ b8f4e7da-7974-4fe7-82a4-35b43f82bd48
all_objects = vcat(others, feps, non_feps)

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
	trait = (i ~ UniformDraw([:trait1, :trait2, :trait3, :trait4]))(ω)
    value = (i ~ Bernoulli())(ω)
  return x -> (x[trait] == value)
end

# ╔═╡ a216de95-eff3-4c03-abb0-00696d75b800
function sample_conj(ω, τ, i = 0)
	if (i ~ Bernoulli(τ))(ω)
		c = sample_conj(ω, τ, i + 1)
		p = sample_pred((@uid, i), ω)
		return x -> (c(x) & p(x))
	else
		return sample_pred(i, ω)
	end
end

# ╔═╡ 89347c29-db8a-4b5a-96e9-39530173d863
x = (trait1 = true, trait2 = true, trait3 = true, trait4 = true, fep = 1)

# ╔═╡ 04549696-5c3e-4439-83d6-ead8a5d438b5
function get_formula(ω, τ, i = 0)
	if (i ~ Bernoulli(τ))(ω)
		c = sample_conj(ω, τ, i + 1)
		f = get_formula(ω, i + 1)
		return x -> (c(x) | f(x))
	else
		return sample_conj(ω, τ, @uid)
	end
end

# ╔═╡ 48ee1509-35ac-4e8b-ae99-f8b7250ef886
obs_fn(x, ω) = 
	(@~ Bernoulli(ifelseₚ(get_formula(ω, τ)(x), 1 - noise_param, noise_param)))(ω)

# ╔═╡ e30556ea-9c09-4f6b-b726-1c88af5e63c1
evidence(ω) = all(map(x -> (obs_fn(x, ω) == (x.fep == 1)), data))

# ╔═╡ 1d61bf77-41c9-4079-9dfa-e734a836d4c5
rule_posterior =  get_formula |ᶜ evidence

# ╔═╡ c29f86eb-2775-46d0-abed-6bf5c25b3d2a
# scatterplot(randsample(ω -> map(rule_posterior(ω), all_objects), 1000), human_data, marker = :xcross)

# ╔═╡ a66c5002-f6a5-4ece-ab0c-f53c7951ac76
md"""
In addition to achieving a good overall correlation with the data, this model captures the three qualitative effects described above: graded generalization, typicality, and prototype enhancement. Make sure you see how to read each of these effects from the above plot! Goodman, et al, have used to this model to capture a variety of other classic categorization effects ([Goodman et al., 2008](https://scholar.google.com/scholar?q=%22A%20rational%20analysis%20of%20rule-based%20concept%20learning%22)), as well. Thus probabilistic induction of (deterministic) rules can capture many of the graded effects previously taken as evidence against rule-based models.

### Grammar-based induction
What is the general principle in the two above examples? We can think of it as the following recipe: we build hypotheses by stochastically choosing between primitives and combination operations, this specifies an infinite “language of thought”; each expression in this language in turn specifies the likelihood of observations. Formally, the stochastic combination process specifies a probabilistic grammar; which yields terms compositionally interpreted into a likelihood over data. A small grammar can generate an infinite array of potential hypotheses; because grammars are themselves generative processes, a prior is provided for free from this formulation.

This style of compositional concept induction model, can be naturally extended to complex hypothesis spaces, each defined by a grammar. For instance to model theory acquisition, learning natural numbers concepts, and many others. See:

* Compositionality in rational analysis: Grammar-based induction for concept learning. N. D. Goodman, J. B. Tenenbaum, T. L. Griffiths, and J. Feldman (2008). In M. Oaksford and N. Chater (Eds.). The probabilistic mind: Prospects for Bayesian cognitive science.

* A Bayesian Model of the Acquisition of Compositional Semantics. S. T. Piantadosi, N. D. Goodman, B. A. Ellis, and J. B. Tenenbaum (2008). Proceedings of the Thirtieth Annual Conference of the Cognitive Science Society.

* Piantadosi, S. T., & Jacobs, R. A. (2016). Four Problems Solved by the Probabilistic Language of Thought. Current Directions in Psychological Science, 25(1).
"""

# ╔═╡ Cell order:
# ╠═f573a320-6700-11ec-06d3-9553fe4dd603
# ╟─7c6b8acd-40e2-4eb8-aefc-34fe23f6d46b
# ╠═51327bd3-0c04-48b1-b7db-b6bb5a7ac6b9
# ╠═63caf0d9-6e91-40e2-8529-af7c2610b67f
# ╠═e14a2bc6-7b78-40b5-96c1-deaedffb2552
# ╠═34bb61a2-260b-449d-9c41-af8bbd3ad141
# ╟─4ec92d6c-56bf-441b-9443-ea59364404c7
# ╠═df6bacaf-ef1b-46c6-b99b-d9ee06debf4d
# ╟─11c2c5b9-aee6-4a70-904b-798970398bed
# ╟─3c8efb48-d333-4461-ad82-e680ca86163e
# ╠═90294f8f-83ac-4101-84fa-0984467a5cef
# ╠═eff3ce23-e1db-40b9-8aae-8b9520299b36
# ╟─9a22ab15-d0fd-4636-99c8-c3cd3f8a03cf
# ╟─3dbd9ef4-f995-4aa3-b939-5baf36225f05
# ╟─17bba76a-c480-4186-b42d-9eb4b26c7a53
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
# ╠═a216de95-eff3-4c03-abb0-00696d75b800
# ╠═89347c29-db8a-4b5a-96e9-39530173d863
# ╠═04549696-5c3e-4439-83d6-ead8a5d438b5
# ╠═48ee1509-35ac-4e8b-ae99-f8b7250ef886
# ╠═e30556ea-9c09-4f6b-b726-1c88af5e63c1
# ╠═1d61bf77-41c9-4079-9dfa-e734a836d4c5
# ╠═c29f86eb-2775-46d0-abed-6bf5c25b3d2a
# ╟─a66c5002-f6a5-4ece-ab0c-f53c7951ac76
