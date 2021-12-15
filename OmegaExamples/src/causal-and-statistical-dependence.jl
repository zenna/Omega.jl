### A Pluto.jl notebook ###
# v0.17.1

using Markdown
using InteractiveUtils

# ╔═╡ c08b8e40-5759-11ec-0aa3-2fe92a5c73af
begin
	import Pkg
    # activate the shared project environment
    Pkg.activate(Base.current_project())
    using Omega, Distributions, UnicodePlots
end

# ╔═╡ ff1115c2-6e2a-49af-93dd-610a1346fb5f
md"## Causal Dependence"

# ╔═╡ 7380e30d-6b9a-438c-8fc2-2521861db9be
md"""
Probabilistic programs encode knowledge about the world in the form of causal models, and it is useful to understand how their function relates to their structure by thinking about some of the intuitive properties of causal relations. Causal relations are local, modular, and directed. 

* They are _modular_ in the sense that any two arbitrary events in the world are most likely causally unrelated, or independent. If they are related, or dependent, the relation is only very weak and liable to be ignored in our mental models. 

* Causal structure is _local_ in the sense that many events that are related are not related directly: They are connected only through causal chains of several steps, a series of intermediate and more local dependencies. 

* And the basic dependencies are directed: when we say that $A$ causes $B$, it means something different than saying that $B$ causes $A$. The _causal influence_ flows only one way along a causal relation—we expect that manipulating the cause will change the effect, but not vice versa — but _information_ can flow both ways—learning about either event will give us information about the other.
"""

# ╔═╡ 26730848-ca65-4075-9a03-fc1790e4f51f
md"""
Let’s examine this notion of “causal dependence” a little more carefully. What does it mean to believe that $A$ depends causally on $B$? Viewing cognition through the lens of probabilistic programs, the most basic notions of causal dependence are in terms of the structure of the program and the flow of evaluation (or “control”) in its execution. We say that expression $A$ causally depends on expression $B$ if it is necessary to evaluate $B$ in order to evaluate $A$. (More precisely, expression $A$ depends on expression $B$ if it is ever necessary to evaluate $B$ in order to evaluate $A$.) For instance, in this program `A` depends on `B` but not on `C` (the final expression depends on both `A` and `C`):
"""

# ╔═╡ 90e1ff24-2747-45ec-b785-9b929ddf231a
let
	C = @~ Bernoulli()
	B = @~ Bernoulli()
	A(ω) = B(ω) ? (@~ Bernoulli(0.1))(ω) : (@~ Bernoulli(0.4))(ω)
	randsample(A |ₚ C)
end

# ╔═╡ 5b86b373-c48a-4f04-b84b-66434da0507a
md"""
Note that causal dependence order is weaker than a notion of ordering in time—one expression might happen to be evaluated before another in time (for instance `C` before `A`), but without the second expression requiring the first. (This notion of causal dependence is related to the notion of [flow dependence](https://en.wikipedia.org/wiki/Dependence_analysis) in the programming language literature.)

For example, consider a simpler variant of our medical diagnosis scenario:
"""

# ╔═╡ 0f7afd5c-38de-4b29-82e1-897eb2965928
smokes = @~ Bernoulli(0.2)

# ╔═╡ a5f62e00-f02f-4545-be25-eddcce5f7e52
lung_disease = (smokes &ₚ (@~ Bernoulli(0.1))) |ₚ (@~ Bernoulli(0.001))

# ╔═╡ 309770fe-bb69-4fe6-a67a-de91a986fda7
cold = @~ Bernoulli(0.02)

# ╔═╡ e7933f47-1cef-44ad-bbbf-271a07451127
cough = pw(|, (cold &ₚ @~ Bernoulli()), (lung_disease &ₚ @~ Bernoulli()), @~ Bernoulli(0.001))

# ╔═╡ c4564628-3072-4780-9bea-e25926a1abc2
fever = (cold &ₚ @~ Bernoulli()) |ₚ @~ Bernoulli(0.01)

# ╔═╡ b579648a-5432-4ce0-a7ae-aac9f90ebd12
chest_pain = (lung_disease &ₚ @~ Bernoulli(0.2)) |ₚ @~ Bernoulli(0.01)

# ╔═╡ df620afa-cb16-40af-bb1f-20a58019fd57
shortness_of_breath = (lung_disease &ₚ @~ Bernoulli(0.2)) |ₚ @~ Bernoulli(0.01)

# ╔═╡ 833d71f7-ec50-45b1-bab1-8bf9fb2867bd
cold_cond = cold |ᶜ cough

# ╔═╡ 27680eca-bd6a-427f-9537-08e33c96c873
histogram(randsample(cold_cond, 100), bins = 1)

# ╔═╡ facacf68-ba53-4aa4-8c1a-5cb34c7effcb
lung_disease_cond = lung_disease |ᶜ cough

# ╔═╡ a4c2bfec-e14e-4bfb-a6f4-560671f417b6
histogram(randsample(lung_disease_cond, 100), bins = 1)

# ╔═╡ e5251e1d-7823-4e99-acd2-98fccdcf68ed
md"""
Here, `cough` depends causally on both `lung_disease` and `cold`, while `fever` depends causally on `cold` but not `lung_disease`. We can see that `cough` depends causally on `smokes` but only indirectly: although `cough` does not call `smokes` directly, in order to evaluate whether a patient coughs, we first have to evaluate the expression `lung_disease` that must itself evaluate `smokes`.

We haven’t made the notion of “direct” causal dependence precise: do we want to say that `cough` depends directly on `cold`, or only directly on the expression `(cold &ₚ @~ Bernoulli()) |ₚ ...`? This can be resolved in several ways that all result in similar intuitions. For instance, we could first re-write the program into a form where each intermediate expression is named (called A-normal form) and then say direct dependence is when one expression immediately includes the name of another.

There are several special situations that are worth mentioning. In some cases, whether expression $A$ requires expression $B$ will depend on the value of some third expression $C$. For example, here is a particular way of writing a noisy - AND relationship:
"""

# ╔═╡ 8d748761-173f-4675-bc69-6218c1541817
let
	C = @~ Bernoulli()
	B = @~ Bernoulli()
	A(ω) = (C(ω) ? (B(ω) ? (@~ Bernoulli(0.85))(ω) : false) : false)
	randsample(A)
end

# ╔═╡ 71001937-1be6-4e68-936e-57f164b84e54
md"`A` always requires `C`, but only evaluates `B` if `C` returns true. Under the above definition of causal dependence `A` depends on `B` (as well as `C`). However, one could imagine a more fine-grained notion of causal dependence that would be useful here: we could say that `A` depends causally on `B` only in certain contexts (just those where `C` happens to return true and thus `A` calls `B`)."

# ╔═╡ 84190fe8-fb92-4cbb-9870-a0f5e8eb7873
md"Another nuance is that an expression that occurs inside a function body may get evaluated several times in a program execution. In such cases it is useful to speak of causal dependence between specific evaluations of two expressions. (However, note that if a specific evaluation of `A` depends on a specific evaluation of `B`, then any other specific evaluation of `A` will depend on some specific evaluation of `B`)"

# ╔═╡ 3bf0f745-1d50-4321-9d30-31c81cb0ba3c
md"### Detecting Dependence Through Intervention"

# ╔═╡ 0ac222fe-5749-4122-b8c3-66f7ef237c60
md"""
The causal dependence structure is not always immediately clear from examining a program, particularly where there are complex functions calls. Another way to detect (or according to some philosophers, such as Jim Woodward, to _define_) causal dependence is more operational, in terms of “difference making”: If we manipulate $A$, does $B$ tend to change? By _manipulate_ here we don’t mean an assumption in the sense of conditioning. Instead we mean actually edit, or _intervene on_, the program in order to make an expression have a particular value independent of its (former) causes. If setting $A$ to different values in this way changes the distribution of values of $B$, then $B$ causally depends on $A$.
"""

# ╔═╡ 20c806d6-fbfd-41fb-8b76-c7cb4b856ca0
md"""
This method is known in the causal Bayesian network literature as the “do operator” or graph surgery (Pearl, 1988). It is also the basis for interesting theories of counterfactual reasoning by Pearl and colleagues (Halpern, Hitchcock and others).
"""

# ╔═╡ 878a4b36-a509-478a-812a-ac2a814de89b
md"""
For example, in the above example of medical diagnosis, we now give our hypothetical patient a cold — for example, by exposing him to a strong cocktail of cold viruses. We should not model this as an observation (e.g. by conditioning on having a cold), because we have taken direct action to change the normal causal structure. Instead we implement intervention by directly editing the random variables:
"""

# ╔═╡ e1ce6bfa-f414-4d6c-8dac-a22c60823e01
cough_intervened = cough |ᵈ (cold => true)

# ╔═╡ 34b54b3e-6581-450d-8685-ce50b85ae836
histogram(randsample(cough_intervened, 100), bins = 1)

# ╔═╡ a7e319f7-934c-4eae-86bf-65006b501ff9
md"""
You should see that the distribution on `cough` changes: coughing becomes more likely if we know that a patient has been given a cold by external intervention. But the reverse is not true: Try forcing the patient to have a cough (e.g., with some unusual drug or by exposure to some cough-inducing dust) by writing `cough => true` instead of `cold => true`: the distribution on `cold` is unaffected. We have captured a familiar fact: treating the symptoms of a disease directly doesn’t cure the disease (taking cough medicine doesn’t make your cold go away), but treating the disease _does_ relieve the symptoms.

Verify in the program above that the method of manipulation works also to identify causal relations that are only indirect: for example, force a patient to smoke and show that it increases their probability of coughing, but not vice versa.

If we are given a program representing a causal model, and the model is simple enough, it is straightforward to read off causal dependencies from the program code itself. However, the notion of causation as difference-making may be easier to compute in much larger, more complex models—and it does not require an analysis of the program code. As long as we can modify (or imagine modifying) the definitions in the program and can run the resulting model, we can compute whether two events or functions are causally related by the difference-making criterion.
"""

# ╔═╡ 43470496-9891-4bb1-a1e4-95d418577214
md"### Statistical Dependence"

# ╔═╡ 9742a40a-8a85-4320-8e4c-91c81562bf65
md"""
One often hears the warning, “correlation does not imply causation”. By “correlation” we mean a different kind of dependence between events or functions—statistical dependence. We say that $A$ and $B$ are statistically dependent, if learning information about $A$ tells us something about $B$, and vice versa. Statistical dependence is a symmetric relation between events referring to how information flows between them when we observe or reason about them. (If conditioning on $A$ changes $B$, then conditioning on $B$ also changes $A$) The fact that we need to be warned against confusing statistical and causal dependence suggests they are related, and indeed, they are. In general, if $A$ causes $B$, then $A$ and $B$ will be statistically dependent. (One might even say the two notions are “causally related”, in the sense that causal dependencies give rise to statistical dependencies.)

Diagnosing statistical dependence by conditioning is similar to diagnosing causal dependence through intervention. We condition on various values of the possible statistical dependent, here $A$, and see whether it changes the distribution on the target, here $B$:
"""

# ╔═╡ 3f9caefe-3d3d-4856-94d8-5d9633e5f02c
A = @~ Bernoulli()

# ╔═╡ 83d8805d-29ce-4a5e-86e7-20ff8169e75a
C = @~ Bernoulli()

# ╔═╡ fd9cd041-792d-4489-bf69-4f6680e9efb9
B(ω) = C(ω) ? (@~ Bernoulli(0.1))(ω) : (@~ Bernoulli(0.4))(ω)

# ╔═╡ 4cd4bcd9-21ac-455b-a086-0b4502b10617
histogram(randsample((B |ᶜ (C ==ₚ true)), 1000), bins = 1)

# ╔═╡ 6418a755-32b8-491d-85d1-67683f4a05f8
histogram(randsample((B |ᶜ (C ==ₚ false)), 1000), bins = 1)

# ╔═╡ 94846995-9616-4ea9-b0de-de065960fd57
md"""
Because the two distributions on $B$ (when we have different information about $C$) are different, we can conclude that $B$ statistically depends on $B$. Do the same procedure for testing if $C$ statistically depends on $B$. How is this similar (and different) from the causal dependence between these two? As an exercise, make a version of the above medical example to test the statistical dependence between cough and cold. Verify that statistical dependence holds symmetrically for events that are connected by an indirect causal chain, such as smokes and coughs.

Correlation is not just a symmetrized version of causality. Two events may be statistically dependent even if there is no causal chain running between them, as long as they have a common cause (direct or indirect). Here is an example of statistical dependence generated by a common cause:
"""

# ╔═╡ d6a546ac-56f3-459f-a774-bdf248337af1
X  = @~ Bernoulli()

# ╔═╡ d41077b8-eaf6-474d-8113-a35c82b06a8d
Y(ω) = X(ω) ? (@~ Bernoulli())(ω) : (@~ Bernoulli(0.9))(ω)

# ╔═╡ 1df8c40c-c894-4fa2-b80f-91a5f5f3bfd1
Z(ω) = X(ω) ? (@~ Bernoulli(0.1))(ω) : (@~ Bernoulli(0.4))(ω)

# ╔═╡ 24f23296-cb77-481a-a8ac-05ec3ed65bcf
histogram(randsample((Z |ᶜ (Y ==ₚ true)), 100), bins = 1)

# ╔═╡ c285f6c4-ae2d-4d2b-900e-7bf31482fdba
histogram(randsample((Z |ᶜ (Y ==ₚ false)), 100), bins = 1)

# ╔═╡ 2fa92448-bc3b-49df-bebf-32e443487d7c
md"""
Situations like this are extremely common. In the medical example above, `cough` and `fever` are not causally dependent but they are statistically dependent, because they both depend on `cold`; likewise for `chest_pain` and `shortness_of_breath` which both depend on `lung_disease`. Here we can read off these facts from the program definitions, but more generally all of these relations can be diagnosed by reasoning using `intervene`.

Successful learning and reasoning with causal models typically depends on exploiting the close coupling between causation and correlation. Causal relations are typically unobservable, while correlations are observable from data. Noticing patterns of correlation is thus often the beginning of causal learning, or discovering what causes what. On the other hand, with a causal model already in place, reasoning about the statistical dependencies implied by the model allows us to predict many aspects of the world not directly observed from those aspects we do observe.
"""

# ╔═╡ 61390b9e-ef3b-4c80-849b-b9494ec66841
md"### Graphical Notations for Dependence"

# ╔═╡ 2b963e9b-1a11-4223-9807-ec4a02a51f20
md"""
_Graphical models_ are an extremely important idea in modern machine learning: a graphical diagram is used to represent the direct dependence structure between random choices in a probabilistic model. A special case are _Bayesian networks_, in which there is a node for each random variable (an expression in our terms) and a link between two nodes if there is a direct conditional dependence between them (a direct causal dependence in our terms). The sets of nodes and links define a _directed acyclic graph_ (hence the term graphical model), a data structure over which many efficient algorithms can be defined. Each node has a _conditional probability table_ (CPT), which represents the probability distribution of that node, given values of its parents. The joint probability distribution over random variables is given by the product of the conditional distributions for each variable in the graph.
"""

# ╔═╡ 97cf5a87-fc8d-4cf8-8a87-48eace44c04a
md"""
Simple generative models will have a corresponding graphical model that captures all of the dependencies (and independencies) of the model, without capturing the precise form of these functions. The CPTs provide a less compact representation of the conditional probabilities compared to Omega programs.

More complicated generative models, which can be expressed as probabilistic programs, often don’t have such a graphical model (or rather they have many approximations, none of which captures all independencies). Recursive models generally give rise to such ambiguous (or loopy) Bayes nets.
"""

# ╔═╡ Cell order:
# ╠═c08b8e40-5759-11ec-0aa3-2fe92a5c73af
# ╟─ff1115c2-6e2a-49af-93dd-610a1346fb5f
# ╟─7380e30d-6b9a-438c-8fc2-2521861db9be
# ╟─26730848-ca65-4075-9a03-fc1790e4f51f
# ╠═90e1ff24-2747-45ec-b785-9b929ddf231a
# ╟─5b86b373-c48a-4f04-b84b-66434da0507a
# ╠═0f7afd5c-38de-4b29-82e1-897eb2965928
# ╠═a5f62e00-f02f-4545-be25-eddcce5f7e52
# ╠═309770fe-bb69-4fe6-a67a-de91a986fda7
# ╠═e7933f47-1cef-44ad-bbbf-271a07451127
# ╠═c4564628-3072-4780-9bea-e25926a1abc2
# ╠═b579648a-5432-4ce0-a7ae-aac9f90ebd12
# ╠═df620afa-cb16-40af-bb1f-20a58019fd57
# ╠═833d71f7-ec50-45b1-bab1-8bf9fb2867bd
# ╠═27680eca-bd6a-427f-9537-08e33c96c873
# ╠═facacf68-ba53-4aa4-8c1a-5cb34c7effcb
# ╠═a4c2bfec-e14e-4bfb-a6f4-560671f417b6
# ╟─e5251e1d-7823-4e99-acd2-98fccdcf68ed
# ╠═8d748761-173f-4675-bc69-6218c1541817
# ╟─71001937-1be6-4e68-936e-57f164b84e54
# ╟─84190fe8-fb92-4cbb-9870-a0f5e8eb7873
# ╟─3bf0f745-1d50-4321-9d30-31c81cb0ba3c
# ╟─0ac222fe-5749-4122-b8c3-66f7ef237c60
# ╟─20c806d6-fbfd-41fb-8b76-c7cb4b856ca0
# ╟─878a4b36-a509-478a-812a-ac2a814de89b
# ╠═e1ce6bfa-f414-4d6c-8dac-a22c60823e01
# ╠═34b54b3e-6581-450d-8685-ce50b85ae836
# ╟─a7e319f7-934c-4eae-86bf-65006b501ff9
# ╟─43470496-9891-4bb1-a1e4-95d418577214
# ╟─9742a40a-8a85-4320-8e4c-91c81562bf65
# ╠═3f9caefe-3d3d-4856-94d8-5d9633e5f02c
# ╠═83d8805d-29ce-4a5e-86e7-20ff8169e75a
# ╠═fd9cd041-792d-4489-bf69-4f6680e9efb9
# ╠═4cd4bcd9-21ac-455b-a086-0b4502b10617
# ╠═6418a755-32b8-491d-85d1-67683f4a05f8
# ╟─94846995-9616-4ea9-b0de-de065960fd57
# ╠═d6a546ac-56f3-459f-a774-bdf248337af1
# ╠═d41077b8-eaf6-474d-8113-a35c82b06a8d
# ╠═1df8c40c-c894-4fa2-b80f-91a5f5f3bfd1
# ╠═24f23296-cb77-481a-a8ac-05ec3ed65bcf
# ╠═c285f6c4-ae2d-4d2b-900e-7bf31482fdba
# ╟─2fa92448-bc3b-49df-bebf-32e443487d7c
# ╟─61390b9e-ef3b-4c80-849b-b9494ec66841
# ╟─2b963e9b-1a11-4223-9807-ec4a02a51f20
# ╟─97cf5a87-fc8d-4cf8-8a87-48eace44c04a
