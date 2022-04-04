### A Pluto.jl notebook ###
# v0.14.5

using Markdown
using InteractiveUtils

# ╔═╡ 70b737a2-a9b2-11eb-1f6f-a330281aaaeb
using Omega

# ╔═╡ 305de14b-4732-4abf-ac08-c542b1bf0203
using CSV

# ╔═╡ f8ac57f8-680a-4246-b2a2-92714c38c167
using DataFrames

# ╔═╡ 4d5a4967-d8c6-4bf9-8c16-c1486d39b334
using Plots

# ╔═╡ 0d6a1f13-1b0c-46c0-8885-23530fd9a02c
using Query

# ╔═╡ e8195cc0-45c8-4edd-b3bc-425f0f902645
using VegaLite

# ╔═╡ 601b0f0d-5dab-43c2-9440-5254c802a3dc
using Distributions

# ╔═╡ 46fcaa08-ba11-41f4-aa65-9cc5ac9f44ec
md"# Inferring Degrees of Racial Descrimination through Bayesian Inference from Police Stopping Data"

# ╔═╡ 3f4880ba-65f2-4dd0-8eed-2d4f811fb8b0
md""" ## The Data
The data here is of police stops in San Diego
"""

# ╔═╡ 71b12af6-1886-4af9-bd3b-a7f06d89f83b
datapath = joinpath(dirname(pathof(Omega)), "..", "examples")

# ╔═╡ 847d6099-c655-4a92-a39a-ec7ae9982848
pd = DataFrame(CSV.File(joinpath(datapath, "sandiegopolicestops.csv")))

# ╔═╡ 471dea65-1eb1-415f-89bc-0612d7d88ed2
x = @from i in pd begin
    @where i.race_category == "Black"
    @select {i.block, i.land_mark}
    @collect DataFrame
end;

# ╔═╡ 1a4e1fb2-9c59-4cca-b925-ba06947f82ce
md"""# Stopping Test

The basic idea behind the threshold test is the following.

Suppose there is a disparity between the the rate at which members of minority groups are being stopped compared to non-minority groups.

Alone, this evidence is not sufficient to prove bias against the minority groups because there may be other causal factors that lead to the same conclusion.  For example, ethnic minorities tend to live in cities, which have a higher density of police offers.

One indication that disparities in stopping are indeed due to discrimination are if there are disparities in the rates at which the stops were justified.
A justified stop for example is one where an illegal weapon was found on the participant.

However the presence of a disparity is still insufficient to indicate bias.
This can be demonstrated through a counterexample: it's possible for a police offer to adopt a completely random (and hence indifferent to race) criteria by which they choose to stop someone, but there still to be differences in the justified stopping rates.
"""

# ╔═╡ e8d79dfc-13b3-4ae1-bc19-0d4eadd60cdc
md"""## A Bayesian Model

We will model an encounter between a police officer and a civillian.  The basic setup is as follows:

- A police-officer encounters a civillian
- Based on the civillian's race and the location, the officer infers a belief $p$ which represents the probability that the civillian is carrying a weapon
- The police-offer actually executes a search if $p$ exceeds some threshold $t_r$ which is race specific.

We use Bayesian inference to infer the thresholds for different races.  Any major disparity of $t_r$ between races indicates discrimination.
"""

# ╔═╡ 71ab4e3a-3888-480e-aa7e-82cc771f6c55
md"First we extract the race categories from the dataset"

# ╔═╡ cd2e8516-68f8-4c72-baf6-11cbbfd721ec
#race_categories = (@from i in pd begin
#    @select i.race_category
#	end) |> @unique() |> collect

# ╔═╡ 71b4adbc-4f84-4d9a-a158-4a3667881a4a
race_categories = ["Black", "White"]

# ╔═╡ ad52aaa5-fbb5-4747-9554-e536b81f1736
md"Let's add a little helper function to get the race index from the string"

# ╔═╡ 4a0aa2ef-654c-4bec-8d88-3ac5af3f0a94
race_id(race) = findfirst(x -> x == race, race_categories);

# ╔═╡ 8a174224-9e12-43aa-96be-fb0e3e951c2a
n_races = length(race_categories)

# ╔═╡ c92c75a7-2a72-4520-a03b-39116e7106ac
md"The following function `risk` constructs the parameters for the risk distribution as a function of race, as indicated by its id `i` (which spans from 1 to the total number of races `n_races`)"

# ╔═╡ a6678b03-f493-447e-83db-b63a03028744
risk(i) =
  (ϕ_r = (i, 1, 1) ~ Normal(0, 1),
   ϕ_d = (i, 2, 1) ~ Normal(0, 1),
   λ_r = (i, 3, 1) ~ Normal(0, 1),
   λ_d = (i, 4, 1) ~ Normal(0, 1))

# ╔═╡ ae577e52-8ced-46b9-a1ea-ee1098428de4
md"For each race category we assume there is an independent risk distribution"

# ╔═╡ 825b4d05-78f7-4619-a9c8-54f016dfd7f4
risks = map(risk, 1:n_races);

# ╔═╡ de8c1f27-6dc3-477f-b5e1-9e89d608bf92
md"In addition, for each race category there is a threshold value $t_r$, above which, the model suggests that a person will be searched"

# ╔═╡ d59e8d13-cce1-4ef2-b14c-27604fd42f3f
thresholds = [(i, 2) ~ Beta(1, 2) for i = 1:n_races];

# ╔═╡ 09fd183f-8677-4922-b86e-bf786b667bbe
invlogit(x) = (e = exp(x); e / (e + 1))

# ╔═╡ 5a63da51-65fe-4c8d-8821-78a4644c509a
md"Finally we can construct the stopping model.  Models in Omega are normal Julia functions which take as input ω (which we can think of as an random number generator object, or if we are more mathematically inclined as an element in probability space."

# ╔═╡ 1b73ba1c-3e7b-4594-a8fb-9e1835ebf3cc
function stop(id, ω)
	race_ = ω |> ((id, 3) ~ DiscreteUniform(1, n_races))
	
	# Get risk parameters
	riskp = risks[race_]
	
	# Construct beta distribution priors
	ϕ_rd = invlogit(riskp.ϕ_r(ω) + riskp.ϕ_d(ω))
	λ_rd = exp(riskp.λ_r(ω) + riskp.λ_d(ω))
	
	# Draw $p$ -- belief weapon-carrying from Beta
	p = ω |> ((id, 4) ~ Beta(ϕ_rd, λ_rd))
	
	# Draw threshold (as function of race)
	thresh = thresholds[race_](ω)
	
	# Officer stops if p exceeds threshold
	race_, Int(p > thresh)
end

# ╔═╡ 5afbcc6c-0012-4d10-b1ec-b194899396ba
n = 10

# ╔═╡ 3438de0c-692d-4376-b45e-85de49d95129
md"`stop` models a single data point.  To model multiple data points we next construct `data_size` (conditionally) independent draws from this model"

# ╔═╡ a251f256-3c95-46ac-be85-26aa08ca0eda
stopmany = Mv(1:n, stop)

# ╔═╡ 6bc7da07-7a60-4916-9d2f-3bf4d7838fcf
md"Here's a single sample from `stopmany`"

# ╔═╡ ecb05030-bb6e-40ea-aae8-718eb85a08b7
randsample(stopmany)

# ╔═╡ 92308112-eb7f-42bb-b303-e37dbbc4c0d4
md"We can show the unconditional distribution of the stops vs non-stops";

# ╔═╡ e659f421-19d5-43fe-a9bf-c845494efbe6
histogram(randsample(stopmany));

# ╔═╡ 599a49f2-0b86-4661-8bc8-a8473fe68241
md"""### Conditioning

Finally we can condition the model with data to infer the posterior distribution over $t$.

First, let's construct the actual proposition we want to condition on
"""

# ╔═╡ 1be486c7-cd84-4843-a388-aaadb39881ea
black_threshold = thresholds[race_id("Black")]

# ╔═╡ be0f16df-608f-43fa-accb-5af34c5608cb
d1 = @from i in pd begin
     @where i.search_conducted == 0
	 @where i.race_category in race_categories
     @select (race_id(i.race_category), i.search_conducted)
	 @collect
end;

# ╔═╡ 1b72954e-0a25-40a2-9638-5d6f75ae77bf
d2 = @from i in pd begin
     @where i.search_conducted == 1
     @where i.race_category in race_categories
     @select (race_id(i.race_category), i.search_conducted)
	 @collect
end;

# ╔═╡ 2d70f306-abda-4805-ab8d-0cde05decdc7
data_slice = 
Tuple{Int, Int64}[d1[1:div(n,2)]; d2[1:div(n,2)]]

# ╔═╡ 2a8a54d0-5460-4679-96b7-fbde5c82cf68
data_condition(ω) = stopmany(ω) == data_slice;

# ╔═╡ c52be3dd-6123-418d-837f-b111ce908fdd
md"Construct the posterior distribution"

# ╔═╡ abaa6f63-c89b-4b54-afc3-27316352e9bc
black_threshold_posterior = black_threshold |ᶜ data_condition;

# ╔═╡ 0d8bef6f-92cb-449c-a77a-fd6650a9e586
md"Sample from the posterior distribution"

# ╔═╡ 7aa560da-08b9-4a61-96f0-b24ddb7a6da0
samples = randsample(black_threshold_posterior, 10000; alg = RejectionSample)

# ╔═╡ 4d10e6c7-0824-4258-822c-624e132cd309
histogram(samples)

# ╔═╡ Cell order:
# ╟─46fcaa08-ba11-41f4-aa65-9cc5ac9f44ec
# ╠═70b737a2-a9b2-11eb-1f6f-a330281aaaeb
# ╠═305de14b-4732-4abf-ac08-c542b1bf0203
# ╠═f8ac57f8-680a-4246-b2a2-92714c38c167
# ╠═4d5a4967-d8c6-4bf9-8c16-c1486d39b334
# ╠═0d6a1f13-1b0c-46c0-8885-23530fd9a02c
# ╠═e8195cc0-45c8-4edd-b3bc-425f0f902645
# ╠═601b0f0d-5dab-43c2-9440-5254c802a3dc
# ╟─3f4880ba-65f2-4dd0-8eed-2d4f811fb8b0
# ╟─71b12af6-1886-4af9-bd3b-a7f06d89f83b
# ╠═847d6099-c655-4a92-a39a-ec7ae9982848
# ╟─471dea65-1eb1-415f-89bc-0612d7d88ed2
# ╟─1a4e1fb2-9c59-4cca-b925-ba06947f82ce
# ╟─e8d79dfc-13b3-4ae1-bc19-0d4eadd60cdc
# ╟─71ab4e3a-3888-480e-aa7e-82cc771f6c55
# ╟─cd2e8516-68f8-4c72-baf6-11cbbfd721ec
# ╟─71b4adbc-4f84-4d9a-a158-4a3667881a4a
# ╟─ad52aaa5-fbb5-4747-9554-e536b81f1736
# ╠═4a0aa2ef-654c-4bec-8d88-3ac5af3f0a94
# ╠═8a174224-9e12-43aa-96be-fb0e3e951c2a
# ╟─c92c75a7-2a72-4520-a03b-39116e7106ac
# ╠═a6678b03-f493-447e-83db-b63a03028744
# ╟─ae577e52-8ced-46b9-a1ea-ee1098428de4
# ╠═825b4d05-78f7-4619-a9c8-54f016dfd7f4
# ╟─de8c1f27-6dc3-477f-b5e1-9e89d608bf92
# ╠═d59e8d13-cce1-4ef2-b14c-27604fd42f3f
# ╠═09fd183f-8677-4922-b86e-bf786b667bbe
# ╟─5a63da51-65fe-4c8d-8821-78a4644c509a
# ╠═1b73ba1c-3e7b-4594-a8fb-9e1835ebf3cc
# ╠═5afbcc6c-0012-4d10-b1ec-b194899396ba
# ╟─3438de0c-692d-4376-b45e-85de49d95129
# ╠═a251f256-3c95-46ac-be85-26aa08ca0eda
# ╟─6bc7da07-7a60-4916-9d2f-3bf4d7838fcf
# ╠═ecb05030-bb6e-40ea-aae8-718eb85a08b7
# ╟─92308112-eb7f-42bb-b303-e37dbbc4c0d4
# ╟─e659f421-19d5-43fe-a9bf-c845494efbe6
# ╟─599a49f2-0b86-4661-8bc8-a8473fe68241
# ╠═1be486c7-cd84-4843-a388-aaadb39881ea
# ╟─be0f16df-608f-43fa-accb-5af34c5608cb
# ╟─1b72954e-0a25-40a2-9638-5d6f75ae77bf
# ╟─2d70f306-abda-4805-ab8d-0cde05decdc7
# ╠═2a8a54d0-5460-4679-96b7-fbde5c82cf68
# ╟─c52be3dd-6123-418d-837f-b111ce908fdd
# ╠═abaa6f63-c89b-4b54-afc3-27316352e9bc
# ╟─0d8bef6f-92cb-449c-a77a-fd6650a9e586
# ╠═7aa560da-08b9-4a61-96f0-b24ddb7a6da0
# ╠═4d10e6c7-0824-4258-822c-624e132cd309
