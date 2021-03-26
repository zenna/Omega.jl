### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 07293e64-8d8f-11eb-22d5-177de857c830
using Revise

# ╔═╡ 113d66b4-8d8f-11eb-0f3f-91dccc68148b
using OmegaCore

# ╔═╡ 15a29128-8d8f-11eb-2482-1fd2c6a81e5b
using Distributions

# ╔═╡ 71e48cca-8d91-11eb-06be-83e5843a8052
using Plots

# ╔═╡ 93e8a4d6-8d97-11eb-3bc3-57b4d317b063
md"# Latent Confounders"

# ╔═╡ 6863b6da-8daf-11eb-1c79-69ff3008f7a4
md"""A common query that we want to evaluate is th"""

# ╔═╡ 6e9c4090-8d90-11eb-14e0-516763c50379


# ╔═╡ 75a9f7f8-8d91-11eb-394a-d34b0788f105
gr()

# ╔═╡ 01f47360-8d90-11eb-0c84-d1ec8bb940d2
md"People who consistently smoked an average of less than one cigarette per day over their lifetimes had a 64 percent higher risk of earlier death than never smokers, and those who smoked between one and 10 cigarettes a day had an 87"

# ╔═╡ 3aa8b382-8d8f-11eb-2080-3fe9076830c4
basecancer = 2/1000

# ╔═╡ 19429ae4-8d8f-11eb-250d-4d8b713bca11
nsmoke = 1 ~ Poisson(10)

# ╔═╡ 7eda4c30-8d91-11eb-0d49-ff1f78b66095
histogram(randsample(nsmoke, 1000))

# ╔═╡ fe6fd072-8d92-11eb-0a1c-a5eee1623839
linear(x, m, c) = m*x + c

# ╔═╡ 11bcd9fe-8d93-11eb-3cfa-ed9ba46c74e0
c = 10 ~ Uniform(0.0, 64.0)

# ╔═╡ 16128454-8d93-11eb-3954-5dea0be6c6d7
m = 2 ~ Uniform((87.0 - 64.0)/10.0, 87.0 - 80.0)

# ╔═╡ 208be9e6-8d90-11eb-0fb0-bdc23ba88e5e
imultiplier(ω) = nsmoke(ω) * m(ω) + c(ω)

# ╔═╡ 5523ba5e-8d94-11eb-1ad0-f15982a3766a
histogram(randsample(imultiplier, 1000);
		  title = "Multiplicative factor: increase in cancer rate due to smoking",
           label = false)

# ╔═╡ 980054c2-8daf-11eb-216c-e7e0bd422fff
plot([x -> x*m_ + c_ for (m_, c_) in randsample((m, c), 100)], 0, 100;
	 label = false,
	 color=:blues,
	 title="Function samples",
	 xlabel = "Number of cigarettes smoked over lifetime",
     ylabel = "Multiplicative increase in cancer rate")

# ╔═╡ ee40c62a-8db0-11eb-1363-fd2bdbafdbfc
md"The probability of acquiring cancer is a random variable: the base rate multiplied by the multiplicative factor"

# ╔═╡ 7b8daf52-8d93-11eb-14da-3999f86e9ffd
p(ω) = min(1.0, imultiplier(ω) * basecancer)

# ╔═╡ 1de871d2-8d95-11eb-2d74-e3146bdb32ed
histogram(randsample(p, 1000);
		  title = "Probability of cancer",
          label = false)

# ╔═╡ bda18ac4-8d90-11eb-3560-8b9d65d24aa7
cancer = 3 ~ Bernoulli(p)

# ╔═╡ 64864aac-8d8f-11eb-0cc1-3f12e9d3bf22
prob(x; n = 1000) = mean(randsample(x, n))

# ╔═╡ 6497eeb8-8db1-11eb-2b5c-c314d28ebc53
md"The *treatment effect* is"

# ╔═╡ 88b5094e-8d90-11eb-0ebd-ff49cf28fa0c
treatment_effect = cancer -ₚ intervene(cancer, nsmoke => nsmoke *ₚ 0.5);

# ╔═╡ b5b67b82-8db1-11eb-29e0-0d62a2f307c0
md"The average treatment effect is simply the expectation: $E(t)$"

# ╔═╡ ab056dd6-8d95-11eb-34ce-2b9540520c55
ate = prob(treatment_effect)

# ╔═╡ b61b3768-8d96-11eb-2971-7b6bd7f468b1
lprob(x) = ω -> prob(x(ω))

# ╔═╡ e8292952-8db1-11eb-1208-21ed90d499e3
md"""We can use the random conditional distribution (or in this case, equivalently but more efficiently the random interventional distribution) to compute the distribution over the average treatment effect (which is a distribution over probabilities)"""

# ╔═╡ 9a5887c4-8d96-11eb-0d06-ed7b4b6bbc69
ate_high = lprob(rid(treatment_effect, m))

# ╔═╡ cec6ff0e-8d96-11eb-3683-1d894ce6524f
histogram(randsample(ate_high, 1000))

# ╔═╡ 299258b4-8db2-11eb-1fb2-594026226ef3
ate_high_c = lprob(rid(treatment_effect, c))

# ╔═╡ 41fa4df8-8db2-11eb-13f3-bd0d4c27e269
histogram(randsample(ate_high_c, 1000))

# ╔═╡ Cell order:
# ╟─93e8a4d6-8d97-11eb-3bc3-57b4d317b063
# ╠═6863b6da-8daf-11eb-1c79-69ff3008f7a4
# ╠═07293e64-8d8f-11eb-22d5-177de857c830
# ╠═113d66b4-8d8f-11eb-0f3f-91dccc68148b
# ╠═15a29128-8d8f-11eb-2482-1fd2c6a81e5b
# ╠═6e9c4090-8d90-11eb-14e0-516763c50379
# ╠═71e48cca-8d91-11eb-06be-83e5843a8052
# ╠═75a9f7f8-8d91-11eb-394a-d34b0788f105
# ╟─01f47360-8d90-11eb-0c84-d1ec8bb940d2
# ╠═3aa8b382-8d8f-11eb-2080-3fe9076830c4
# ╠═19429ae4-8d8f-11eb-250d-4d8b713bca11
# ╠═7eda4c30-8d91-11eb-0d49-ff1f78b66095
# ╠═fe6fd072-8d92-11eb-0a1c-a5eee1623839
# ╠═11bcd9fe-8d93-11eb-3cfa-ed9ba46c74e0
# ╠═16128454-8d93-11eb-3954-5dea0be6c6d7
# ╠═208be9e6-8d90-11eb-0fb0-bdc23ba88e5e
# ╠═5523ba5e-8d94-11eb-1ad0-f15982a3766a
# ╠═980054c2-8daf-11eb-216c-e7e0bd422fff
# ╠═ee40c62a-8db0-11eb-1363-fd2bdbafdbfc
# ╠═7b8daf52-8d93-11eb-14da-3999f86e9ffd
# ╠═1de871d2-8d95-11eb-2d74-e3146bdb32ed
# ╠═bda18ac4-8d90-11eb-3560-8b9d65d24aa7
# ╠═64864aac-8d8f-11eb-0cc1-3f12e9d3bf22
# ╠═6497eeb8-8db1-11eb-2b5c-c314d28ebc53
# ╠═88b5094e-8d90-11eb-0ebd-ff49cf28fa0c
# ╠═b5b67b82-8db1-11eb-29e0-0d62a2f307c0
# ╠═ab056dd6-8d95-11eb-34ce-2b9540520c55
# ╠═b61b3768-8d96-11eb-2971-7b6bd7f468b1
# ╠═e8292952-8db1-11eb-1208-21ed90d499e3
# ╠═9a5887c4-8d96-11eb-0d06-ed7b4b6bbc69
# ╠═cec6ff0e-8d96-11eb-3683-1d894ce6524f
# ╠═299258b4-8db2-11eb-1fb2-594026226ef3
# ╠═41fa4df8-8db2-11eb-13f3-bd0d4c27e269
