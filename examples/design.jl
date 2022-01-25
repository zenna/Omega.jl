### A Pluto.jl notebook ###
# v0.17.6

using Markdown
using InteractiveUtils

# ╔═╡ f27baa20-3be9-400c-8e98-e6d9d534754c
using Pkg

# ╔═╡ 7007b9e6-bce3-4a89-9c9f-6e2d480f658f
Pkg.activate(Base.current_project())

# ╔═╡ 14c4144e-abc0-4802-8b26-f8f6f6a0ddc0
using Omega

# ╔═╡ bc0da6fe-5b09-4d49-9bd8-e0530fac0186
using Distributions

# ╔═╡ ad003e86-23b7-4c8e-a6eb-009b1ec73d25
md"# Design


There are a number of key concepts in Omega
- The Ω object
- Random variable classes
- Random variables
- The conditioning operator
- The intervention operator
- Deep interventions
- The random conditional operator
- The random interventional operator
"

# ╔═╡ 50bfb49f-7081-49e7-bda2-503804599d5e
md""" # Omega
The Ω object in Omega.jl is of special importance.

There are a few perspectives on what Ω is:

1. The sample space in probability theory (often denoted $\Omega$)
2. Space of exogenous variables in as causal graphical modelling nomenclature (often denoted $U$)
3. The random number generator `rng::Random.AbstractRNG`.  Implementation wise, Omega.jl tries to be compatible with any model written as a function `f(rng::AbstractRNG)`
"""

# ╔═╡ 99fc08f8-d2b2-11eb-0599-fba4c4ec5a1a
md"## Conditional Independence"

# ╔═╡ eaa2ba5f-e319-4f74-9adc-87be3bc319d2
md"""
A basic object in Omega is a random variable class.  Each class represents a sequence of random variables.  A class is analogous to a *plate* in Bayesian networks.
"""

# ╔═╡ 69ab85c4-2d16-4e67-88a3-6d50d64e5995
md"""### Primitive Classes
Omega comes with a set of built-in primitive random variable classes, such as `StdNormal` and `StdUniform`.  There are parameterless infinite sets of random variables.
"""

# ╔═╡ e1d86ea5-ace0-456d-8ea6-115ae19a8531
As = StdNormal{Float64}()

# ╔═╡ 9cd46715-b64b-4767-adec-2748560189f7
md"To get a member of a random variable class -- a random variable -- we can use the function `nth`, which gives the `nth` memeber of a class."

# ╔═╡ b625bd45-2289-41e3-89d2-613e0313ede7
A1 = nth(As, 1)

# ╔═╡ 135bde41-b4e8-493f-8e84-f367962aaa6c
A2 = nth(As, 2);

# ╔═╡ c92aaaf2-b1c7-4950-b5cb-836bf7f8fc3a
A3 = nth(As, 3);

# ╔═╡ e8fa68c4-8771-4f4f-92e1-35121e0e726a
md"Or equivalently, use `~`:"

# ╔═╡ bced6a62-c745-4c84-8834-9e2f4d1c62e2
A1_ = 1 ~ As;

# ╔═╡ 0515706c-f4c1-44ac-aab6-58da8c006b1d
A2_ = 2 ~ As;

# ╔═╡ a12ce183-2623-4582-86c1-e1cb206bf78c
A3_ = 3 ~ As;

# ╔═╡ 359a7e70-4662-4942-af96-441e24e15839
md"__Possibly talk about:__ IDs, automatic generation"


# ╔═╡ 0d853129-a457-4650-843c-6443d4797b53
md"#### Sampling
You can sample from a random variable using `randsample`"

# ╔═╡ 4a62d4ff-582e-4dc2-ac44-84c48433e078
randsample(A1)

# ╔═╡ 0d5b28d1-5290-4266-b0ee-4c8924c0ec0e
md"""Random variables are simply functions of ω.  Conceptually, `randsample` then does two distinct steps:
1. Construct a random $ω : Ω$
2. Apply $ω$ to $A$
"""

# ╔═╡ 1408729d-8870-4116-834e-7ebb8fcf0732
ω = defω(); # Step 1 default ω (there are many types)

# ╔═╡ cbcd86a4-cece-4847-8cce-55e768ac63c6
A1(ω) # Step 2

# ╔═╡ 6bd0f9bc-95d5-46c8-be44-edefeb561b0e
md"Note that random variables are pure: reapplication produces the same result:"

# ╔═╡ d92b8bc8-28ca-4944-ba4a-a357f4139014
A1(ω)

# ╔═╡ 0587686f-9087-491c-8301-2f79bbaf2834
md"""__Omega__: In terms of representaiton terms, it is useful to think of Omega is a mapping from a primitive set of random variables to values in their domains."""

# ╔═╡ a5e82bc2-fcce-448c-99ed-a01cda32ac7f
md"### Composite Classes
A class in Omega is actually just function of the form `f(id, ω)`.
Of course, you can specify your own classes simply by constructing a function."

# ╔═╡ 4ccae103-1a6d-42cf-8546-9ccdae847ba5
μ = 0 ~ StdNormal{Float64}()

# ╔═╡ 521de9f7-e941-481e-aa0d-21a263ae19b7
Xs(id, ω) = (id ~ Normal(μ(ω), 1))(ω);

# ╔═╡ fcbe23a1-6180-4d93-bcb7-17f92668cff6
x1 = 1 ~ Xs

# ╔═╡ d6ea7aa6-568f-4f72-a152-83a60ddac0e3
x2 = 2 ~ Xs

# ╔═╡ c8d985a9-9834-427a-be94-a4777c0cc6bc
ω_ = defω()

# ╔═╡ f64a3156-b9bb-4c51-b76b-1effe872b16b
joint_ = @joint x1 x2 μ

# ╔═╡ ee2e69da-58b0-442b-ba37-da42531082fd
joint_(ω_)

# ╔═╡ d8e425ec-c385-4632-9a6f-a392bb84ede0
ω_

# ╔═╡ 3cea826b-e938-4754-b931-cf1645b77c81
randsample(x1)

# ╔═╡ a877b127-d2d8-48d1-8cde-d819adeaa811
md"To construct a random variable that produces the output of many variables, we simply create a new function"

# ╔═╡ 667dd097-cd63-4642-a838-b706e430a1c6
randsample(ω -> (x1 = x1(ω), x2 = x2(ω), μ = μ(ω)))

# ╔═╡ 759ab4f5-5e7a-42be-9de9-f7f4c0f93045
md"Or for convenience we can just use the `@joint` macro, which does the same thing"

# ╔═╡ e2d93606-afcc-4f8e-a636-e7d6f4167250
joint = @joint x1 x2 μ

# ╔═╡ c301d41f-5b20-4017-a3f4-85dce22e0a90
randsample(joint)

# ╔═╡ 6e43e42f-1633-42d1-a695-71851d123705
md"It is important to note that `x1` and `x2` are __conditionally independent__ given μ"

# ╔═╡ 9f7c47a3-bb65-4c27-a120-6cac16e727fe
md"#### Multivariante Distributions

If we want to construct a array-valued random variable from a class we use `Mv`
"

# ╔═╡ 64cdcb20-3480-4c9c-9865-310729df9b9a
X⃗ = Mv(1:10, Xs)

# ╔═╡ e2bf387e-7c8f-4ab7-af70-8d8c887c3574
randsample(X⃗)

# ╔═╡ 44604569-5983-4f77-a884-acef6fad75c6
md"""## (Full) Independence

Sometimes we need to construct random variables that are independent.  The function `iid` constructs a class of random variables that are independent."""

# ╔═╡ 7ef6607a-9048-4b41-ab33-9d942b7c5e19
iidclass = iid(x1)

# ╔═╡ 3987183c-1dd2-4007-966d-979265f8bda5
x1_iid = 1 ~ iidclass

# ╔═╡ a12cc8e9-1209-433c-939d-5dd7027b3f2c
x2_iid = 2 ~ iidclass

# ╔═╡ ef711fcd-4f01-4aeb-94ce-84b374b5aee4
randsample(@joint x1_iid x2_iid)

# ╔═╡ b849e448-54c5-4a93-a77f-714320e42e11
w_2 = defω()

# ╔═╡ e3437550-fad4-4bc5-b1e4-2a30d92f9991
joint2 = @joint  x1_iid x2_iid

# ╔═╡ f1de6343-81c7-4f2f-a6db-c77de43a74f3
joint2(w_2)

# ╔═╡ 51d2ed1f-ee25-429c-a334-2021d1367083
w_2

# ╔═╡ e77a0d45-7773-4df0-881b-3d89c6cda44e
md"It is important to note that `x1_iid` and `x2_iid` are __independent__ (not conditionally independent) and identically distributed"

# ╔═╡ 4de86493-b2bd-4af5-955b-a6f076ba31eb
md"""__Possibly talk about__: How this works.  Sample space projections"""

# ╔═╡ 585d5f13-bd99-45b1-8dcd-1dae0807b0c2
md"### Random Variable Transformations

There is no explicit concept of a probabilistic model in Omega, but we use the term conceptually to refer to the collection of random variables constructed in a program.

Cosntructing a model usually involves defining new primitive random variables of transforming them.
"

# ╔═╡ 1a423af6-d27d-4420-8bf2-f331607c1d20
md"""Transformations of random variables are themselves random variables.  We can do this explicitly by just creating a new function"""

# ╔═╡ 5f89a9a6-2f01-4444-a372-592dfc6eb963
X⃗sum(ω) = sum(X⃗(ω))

# ╔═╡ 22d84114-43f0-4edd-8588-c13cf558bdd2
randsample(@joint X⃗sum X⃗)

# ╔═╡ 8149622b-106a-46ff-8cc3-cea63d40b672
md"""A particularly important kind of random variable are those which output a Boolean.  They're important, as we shall we in a moment, because they are used for conditioning.  They are constructed in the same way as any other"""

# ╔═╡ 959e14b8-9c3f-4e89-b628-47bb27c97275
evidence(ω) = X⃗sum(ω) < -10.0

# ╔═╡ 5e675bd5-9a83-4944-9700-40ae99ef71ad
evidence_2 = X⃗sum <ₚ -10.0

# ╔═╡ 1732577b-e2c6-45a4-8e2c-ecacdcc548cd
randsample(@joint(evidence, evidence_2), 2)

# ╔═╡ f2a5f9ce-ebd1-49a7-a3bf-17ac0b37bfa7
md"#### Conditioning
Conditioning is then an operation which transforms random variables into conditional random variables"

# ╔═╡ 051a770f-4288-4f6a-b25b-b1d4834501c9
μ_posterior = cnd(μ, evidence)

# ╔═╡ 92067906-96bd-4e43-bf37-4f8da067e3f5
randsample(@joint(μ_posterior,evidence), 3; alg = RejectionSample)

# ╔═╡ c35c4b0c-86ec-4c8f-9444-b641e5c604f1
md"__Possibly talk about__: Likelhood based inference and/or predicate relaxation."

# ╔═╡ acebf7b1-d0de-430e-9cf9-fc264897feb0
md"## Interventions

An interventions in Omega.jl is a kind of program.  Specifically, an intervention transforms one random variable into another.
It is done with `intwrvene`
"

# ╔═╡ 3d12697e-7413-4794-92ea-dd4315d773bd
μ_orig = 1 ~ Normal(0, 1)

# ╔═╡ d99811f7-cfa2-42c8-b5c8-1185dd605aff
X = 2 ~ Normal(μ_orig, 1)

# ╔═╡ ca8b38b4-45b5-4177-a54a-0bcc85e50e91
X_intervene = intervene(X, μ_orig => 200)

# ╔═╡ 443a2396-c95f-4f2a-9fb2-18c0776c1715
randsample(@joint μ_orig X X_intervene)

# ╔═╡ 3775ad8a-13e4-4aba-b57d-0b84082ef855
md"We can also intervene a random variable to be another random variable"

# ╔═╡ bd99057b-dc1b-4cd8-a9d3-c2c9d3b4d952
X_intervene_2 = intervene(X, μ_orig => A1);

# ╔═╡ 99728528-28ed-4ca1-bd91-ea56544067f0
randsample(@joint μ_orig X X_intervene X_intervene_2)

# ╔═╡ 84aa55b1-6b62-4eeb-8be2-9d3d141499c6
md"We can also intervene a random variable to be another a function of itself"

# ╔═╡ 10810035-14b9-4fe9-8180-e08e61d9d199
X_intervene_3 = intervene(X, μ_orig => μ_orig +ₚ 10.0);

# ╔═╡ 54b2923e-0bb7-44b4-839d-d03cdb13c16d
md"For syntactic convenience we can use `|ᵈ`"

# ╔═╡ 5df91e58-e78d-4dd5-b183-5596cb9fa674
X |ᵈ (μ_orig => μ_orig +ₚ 10.0);

# ╔═╡ 3814bf03-c6ea-466d-b057-b8ecc9c2e4bc
treatment(ω) = X(ω) - X_intervene_3(ω)

# ╔═╡ 9eefe547-a8b1-446d-9659-5163647cfe0f
randsample(treatment)

# ╔═╡ 32ed4695-ba78-475b-817b-b6a7d749919a
randsample(@joint μ_orig X X_intervene X_intervene_2 X_intervene_3)

# ╔═╡ e0104f49-2f4c-474a-be93-521c55841833
md"""__Possibly talk about__: How interventions work in Omega.jl -- nonstandard execution"""

# ╔═╡ b8f306ef-3fc1-415d-9830-7b71048f41d9
md"#### Counterfactuals

There's no primitive counterfactual operator in Omega.  Rather, they are constructed by composes `intervene` with `cnd`
"

# ╔═╡ f44bdb57-d04c-488e-bd19-db5986ba4ae4
evidence_X = X >ₚ 0.0

# ╔═╡ f074c347-fe70-43ad-82cf-0befc91a0e33
counterfactual = X_intervene_3 |ᶜ evidence_X

# ╔═╡ 35556a02-d304-46a5-aeff-1f28dab98512
(X |ᵈ (μ_orig => μ_orig +ₚ 10.0)) |ᶜ evidence_X

# ╔═╡ 3cb01bb7-adc8-406b-8711-54cfc830f414
(X |ᶜ evidence_X) |ᵈ (μ_orig => μ_orig +ₚ 10.0)

# ╔═╡ fb8cbcdc-eb16-42cd-81bd-fcae78732f2e
X_posterior = (X |ᶜ evidence_X)

# ╔═╡ a395eb05-09ab-484b-83ce-8b62332cc9c0
@joint X X_posterior

# ╔═╡ ce89139c-ae17-4342-9931-85770fe03491
randsample(counterfactual, 100)

# ╔═╡ a2a0bb64-be53-4056-a1af-37e3fbde9392
md"""__Possibly talk about__: The nesting of the intervention and conditoning may seem counter-intuitive or even wrong, but it is not wrong"""

# ╔═╡ 42bf8f3b-c779-4727-b050-151cadee99ff
md"#### Deep Interventions

Sometimes normal interventions don't quite capture what we want.  For example, in causal discovery we might construct a random variable `X` that is a higher-order random variable in the sense that the values it takes are themselves random variables.  Then, rather than say intervene `X` to `x`, we instead want to say intervene the random variable that is outputted by `X` to `x`.  Omega allows this."

# ╔═╡ 7cb712ba-c478-4010-8604-ae30ffd47e4c
μ_hi = 1 ~ Normal(0, 1);

# ╔═╡ 736d14aa-2104-49e4-a966-c1fc288fbd47
σ_hi = 2 ~ Uniform(1, 3);

# ╔═╡ 5388b8a3-58e4-41b4-b6c9-9c36e3eb757e
y_hi = 3 ~ Normal(μ_hi, σ_hi);

# ╔═╡ f2bd636b-6ba8-4807-a08d-12cc3b4cc206
md"`choice` below flips a coin and returns either `μ_hi` or `σ_hi` -- the random variable itself, not a value from the domain"

# ╔═╡ b955bd92-6cb0-41e7-bc92-0de8dbd497d4
choice(ω) = ifelse((4 ~ Bernoulli(0.5))(ω), μ_hi, σ_hi)

# ╔═╡ 77eda7a7-443f-4c0e-a3d9-49e5baf83f79
randsample(choice)

# ╔═╡ 243cfa89-b756-418f-ab2a-8b015927d9c2
int_dist(ω) = ValueIntervention(choice(ω), 5.0)

# ╔═╡ 86170150-13c7-47a6-a258-51e6d4f59f33
randsample(int_dist)

# ╔═╡ cd0fe624-c809-4b5b-8d85-3f236f034a67
joint_hi = @joint(y_hi, μ_hi, σ_hi, choice)

# ╔═╡ 21971f4c-f973-4ef4-baeb-bd85bef8b167
md"Here we construct the higher order intervention."

# ╔═╡ 4e9b0394-5619-4a65-bbc7-427e2208a2fb
joint_hi_ = joint_hi |ᵈ hi(int_dist)

# ╔═╡ ef243319-4446-49e5-9770-aa3a77bc7ca0
randsample(joint_hi_)

# ╔═╡ 516c1e9e-534f-4acb-a6d5-d5a111c50e37
md"### Higher-Order operators

Omega has two so called higher order extensions of the conditioning operator and the intervention operator.  They are called, respectively, the random conditional distribution operator and the random interventional distribution operator.

In short these allow you to easily:
1. Construct conditional expectations, conditional variances, etc as first class random variables.  Collectively we call these distributional properties as they are not functions of individual samples but of the entire distribution.
2. Condition these distributional properties.  This allows one to add statistical knowledge into a model in a principled way.  We call this distributional inference
"

# ╔═╡ 7f868e1b-78f0-477a-b94e-900ecefd4380
θ = 1 ~ Beta(2.0, 2.0)

# ╔═╡ a04a3fd3-c174-4550-930d-57756e797e7e
x = 2 ~ Bernoulli(θ)

# ╔═╡ 3dbe06f6-6e13-4500-9525-12420b1fd236
ridxθ = rid(x, θ)

# ╔═╡ 89e217e7-b367-4f56-9f07-73fdec358fdd
md"Below are samples from the distribution *over expectations*, i.e. the conditional expectation of `x` given `θ`"

# ╔═╡ 5c20809d-7547-471e-8f4d-6337f1ddb71e
samplemean(x; n = 1000) = mean(randsample(x, n))

# ╔═╡ 071f08a1-f4ab-4d11-be9e-0502475f90cd
meandist(ω) = samplemean(ridxθ(ω))

# ╔═╡ 82974f06-19de-4249-a398-53197b04aeb6
randsample(meandist, 100)

# ╔═╡ Cell order:
# ╠═f27baa20-3be9-400c-8e98-e6d9d534754c
# ╠═7007b9e6-bce3-4a89-9c9f-6e2d480f658f
# ╠═14c4144e-abc0-4802-8b26-f8f6f6a0ddc0
# ╠═bc0da6fe-5b09-4d49-9bd8-e0530fac0186
# ╟─ad003e86-23b7-4c8e-a6eb-009b1ec73d25
# ╟─50bfb49f-7081-49e7-bda2-503804599d5e
# ╟─99fc08f8-d2b2-11eb-0599-fba4c4ec5a1a
# ╟─eaa2ba5f-e319-4f74-9adc-87be3bc319d2
# ╟─69ab85c4-2d16-4e67-88a3-6d50d64e5995
# ╠═e1d86ea5-ace0-456d-8ea6-115ae19a8531
# ╟─9cd46715-b64b-4767-adec-2748560189f7
# ╠═b625bd45-2289-41e3-89d2-613e0313ede7
# ╠═135bde41-b4e8-493f-8e84-f367962aaa6c
# ╠═c92aaaf2-b1c7-4950-b5cb-836bf7f8fc3a
# ╟─e8fa68c4-8771-4f4f-92e1-35121e0e726a
# ╠═bced6a62-c745-4c84-8834-9e2f4d1c62e2
# ╠═0515706c-f4c1-44ac-aab6-58da8c006b1d
# ╠═a12ce183-2623-4582-86c1-e1cb206bf78c
# ╟─359a7e70-4662-4942-af96-441e24e15839
# ╟─0d853129-a457-4650-843c-6443d4797b53
# ╠═4a62d4ff-582e-4dc2-ac44-84c48433e078
# ╟─0d5b28d1-5290-4266-b0ee-4c8924c0ec0e
# ╠═1408729d-8870-4116-834e-7ebb8fcf0732
# ╠═cbcd86a4-cece-4847-8cce-55e768ac63c6
# ╟─6bd0f9bc-95d5-46c8-be44-edefeb561b0e
# ╠═d92b8bc8-28ca-4944-ba4a-a357f4139014
# ╟─0587686f-9087-491c-8301-2f79bbaf2834
# ╟─a5e82bc2-fcce-448c-99ed-a01cda32ac7f
# ╠═4ccae103-1a6d-42cf-8546-9ccdae847ba5
# ╠═521de9f7-e941-481e-aa0d-21a263ae19b7
# ╠═fcbe23a1-6180-4d93-bcb7-17f92668cff6
# ╠═d6ea7aa6-568f-4f72-a152-83a60ddac0e3
# ╠═c8d985a9-9834-427a-be94-a4777c0cc6bc
# ╠═f64a3156-b9bb-4c51-b76b-1effe872b16b
# ╠═ee2e69da-58b0-442b-ba37-da42531082fd
# ╠═d8e425ec-c385-4632-9a6f-a392bb84ede0
# ╠═3cea826b-e938-4754-b931-cf1645b77c81
# ╟─a877b127-d2d8-48d1-8cde-d819adeaa811
# ╠═667dd097-cd63-4642-a838-b706e430a1c6
# ╟─759ab4f5-5e7a-42be-9de9-f7f4c0f93045
# ╠═e2d93606-afcc-4f8e-a636-e7d6f4167250
# ╠═c301d41f-5b20-4017-a3f4-85dce22e0a90
# ╟─6e43e42f-1633-42d1-a695-71851d123705
# ╟─9f7c47a3-bb65-4c27-a120-6cac16e727fe
# ╠═64cdcb20-3480-4c9c-9865-310729df9b9a
# ╠═e2bf387e-7c8f-4ab7-af70-8d8c887c3574
# ╟─44604569-5983-4f77-a884-acef6fad75c6
# ╠═7ef6607a-9048-4b41-ab33-9d942b7c5e19
# ╠═3987183c-1dd2-4007-966d-979265f8bda5
# ╠═a12cc8e9-1209-433c-939d-5dd7027b3f2c
# ╠═ef711fcd-4f01-4aeb-94ce-84b374b5aee4
# ╠═b849e448-54c5-4a93-a77f-714320e42e11
# ╠═e3437550-fad4-4bc5-b1e4-2a30d92f9991
# ╠═f1de6343-81c7-4f2f-a6db-c77de43a74f3
# ╠═51d2ed1f-ee25-429c-a334-2021d1367083
# ╟─e77a0d45-7773-4df0-881b-3d89c6cda44e
# ╟─4de86493-b2bd-4af5-955b-a6f076ba31eb
# ╟─585d5f13-bd99-45b1-8dcd-1dae0807b0c2
# ╟─1a423af6-d27d-4420-8bf2-f331607c1d20
# ╠═5f89a9a6-2f01-4444-a372-592dfc6eb963
# ╠═22d84114-43f0-4edd-8588-c13cf558bdd2
# ╟─8149622b-106a-46ff-8cc3-cea63d40b672
# ╠═959e14b8-9c3f-4e89-b628-47bb27c97275
# ╠═5e675bd5-9a83-4944-9700-40ae99ef71ad
# ╠═1732577b-e2c6-45a4-8e2c-ecacdcc548cd
# ╟─f2a5f9ce-ebd1-49a7-a3bf-17ac0b37bfa7
# ╠═051a770f-4288-4f6a-b25b-b1d4834501c9
# ╠═92067906-96bd-4e43-bf37-4f8da067e3f5
# ╟─c35c4b0c-86ec-4c8f-9444-b641e5c604f1
# ╟─acebf7b1-d0de-430e-9cf9-fc264897feb0
# ╠═3d12697e-7413-4794-92ea-dd4315d773bd
# ╠═d99811f7-cfa2-42c8-b5c8-1185dd605aff
# ╠═ca8b38b4-45b5-4177-a54a-0bcc85e50e91
# ╠═443a2396-c95f-4f2a-9fb2-18c0776c1715
# ╟─3775ad8a-13e4-4aba-b57d-0b84082ef855
# ╠═bd99057b-dc1b-4cd8-a9d3-c2c9d3b4d952
# ╠═99728528-28ed-4ca1-bd91-ea56544067f0
# ╟─84aa55b1-6b62-4eeb-8be2-9d3d141499c6
# ╠═10810035-14b9-4fe9-8180-e08e61d9d199
# ╟─54b2923e-0bb7-44b4-839d-d03cdb13c16d
# ╠═5df91e58-e78d-4dd5-b183-5596cb9fa674
# ╠═3814bf03-c6ea-466d-b057-b8ecc9c2e4bc
# ╠═9eefe547-a8b1-446d-9659-5163647cfe0f
# ╠═32ed4695-ba78-475b-817b-b6a7d749919a
# ╟─e0104f49-2f4c-474a-be93-521c55841833
# ╟─b8f306ef-3fc1-415d-9830-7b71048f41d9
# ╠═f44bdb57-d04c-488e-bd19-db5986ba4ae4
# ╠═f074c347-fe70-43ad-82cf-0befc91a0e33
# ╠═35556a02-d304-46a5-aeff-1f28dab98512
# ╠═3cb01bb7-adc8-406b-8711-54cfc830f414
# ╠═fb8cbcdc-eb16-42cd-81bd-fcae78732f2e
# ╠═a395eb05-09ab-484b-83ce-8b62332cc9c0
# ╠═ce89139c-ae17-4342-9931-85770fe03491
# ╟─a2a0bb64-be53-4056-a1af-37e3fbde9392
# ╟─42bf8f3b-c779-4727-b050-151cadee99ff
# ╠═7cb712ba-c478-4010-8604-ae30ffd47e4c
# ╠═736d14aa-2104-49e4-a966-c1fc288fbd47
# ╠═5388b8a3-58e4-41b4-b6c9-9c36e3eb757e
# ╟─f2bd636b-6ba8-4807-a08d-12cc3b4cc206
# ╠═b955bd92-6cb0-41e7-bc92-0de8dbd497d4
# ╠═77eda7a7-443f-4c0e-a3d9-49e5baf83f79
# ╠═243cfa89-b756-418f-ab2a-8b015927d9c2
# ╠═86170150-13c7-47a6-a258-51e6d4f59f33
# ╠═cd0fe624-c809-4b5b-8d85-3f236f034a67
# ╟─21971f4c-f973-4ef4-baeb-bd85bef8b167
# ╠═4e9b0394-5619-4a65-bbc7-427e2208a2fb
# ╠═ef243319-4446-49e5-9770-aa3a77bc7ca0
# ╟─516c1e9e-534f-4acb-a6d5-d5a111c50e37
# ╠═7f868e1b-78f0-477a-b94e-900ecefd4380
# ╠═a04a3fd3-c174-4550-930d-57756e797e7e
# ╠═3dbe06f6-6e13-4500-9525-12420b1fd236
# ╠═071f08a1-f4ab-4d11-be9e-0502475f90cd
# ╟─89e217e7-b367-4f56-9f07-73fdec358fdd
# ╠═82974f06-19de-4249-a398-53197b04aeb6
# ╠═5c20809d-7547-471e-8f4d-6337f1ddb71e
