### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 80b0b83e-757f-11eb-1512-4b62350fb830
using Revise

# ╔═╡ 8374fde4-757f-11eb-2e1c-abe5ecf25d02
using OmegaIMCMC

# ╔═╡ 86ae4f9e-757f-11eb-07fd-9daa27aae41a
using Plots

# ╔═╡ 30e3b7d8-7580-11eb-26e4-4913ed8ba40c
using Random

# ╔═╡ 36475d28-7581-11eb-20a2-55d445b832f3
using Distributions

# ╔═╡ 6e9dbc6c-757f-11eb-0a43-1b6a3f01f1aa
md"#Involutive MCMC"

# ╔═╡ 89e816f4-757f-11eb-06b3-1d1094d9a25b
md"Involutive MCMC is a mechanism to construct markov chains that compute samples from some target distribution.  Similarly to Metropolis Hastings, it is parameterized by a number of different choices."

# ╔═╡ bf704d84-757f-11eb-26a1-cd7a733b6ac0
rng = Random.MersenneTwister(0)

# ╔═╡ 3884d3b4-7580-11eb-3549-8bbbdd4c0ff7
md"Let's' first construct the target density"

# ╔═╡ 0ab7717a-7581-11eb-3dc8-35536853f805
μ1, μ2 = [2.0, 0.0], [-2.0, 0.0]

# ╔═╡ 1aa926e6-7581-11eb-08ed-2911a3dfb0a8
σ1 = σ2 = [0.5 0
	       0 0.5]

# ╔═╡ d1389aaa-7580-11eb-1338-af09627a4cda
target_dist = MixtureModel([MvNormal(μ1, σ1), MvNormal(μ2, σ2)], [0.5, 0.5]);

# ╔═╡ 4b235bfe-7581-11eb-2a19-092b27730c90
xyrng = -5:0.1:5

# ╔═╡ 4029729a-7581-11eb-2639-51a448011a48
Plots.surface(xyrng, xyrng, (x, y) -> pdf(target_dist, [x, y]))

# ╔═╡ 7519366c-7580-11eb-3b9e-edc42831b839
target(x) = pdf(target_dist, x)

# ╔═╡ cd7804ea-7581-11eb-20b0-8de7d6371441
logtarget(x) = logpdf(target_dist, x)

# ╔═╡ 909b419a-7581-11eb-2381-93c6f4ee6f38
target([2.0, 0.0])

# ╔═╡ 7e20ee3a-7580-11eb-3acf-5906a2c6374a
md"Involution MCMC requires that we define an auxiliary distribution $p(v|x)$"

# ╔═╡ 5e4a80c4-7582-11eb-0694-2d1d9418b6b6
x0 = rand(target_dist)

# ╔═╡ 76dca6f4-7586-11eb-0b9e-f78d1b47240c
p_vₓ(v, x) = pdf(MvNormal(x, 1), v)

# ╔═╡ 39e5449e-75aa-11eb-0831-1986962d0bee
logp_vₓ(v, x) = logpdf(MvNormal(x, 1), v)

# ╔═╡ 662c766e-7582-11eb-3150-513857e0213f
function Vₓ(rng, x)
	v = rand(MvNormal(x, 1))
	# (v, pdf(MvNormal(x, 1), v))
end

# ╔═╡ 9c92e826-7582-11eb-34a2-979d09caac22
involution(x, v) = (v, x)

# ╔═╡ 925c225c-7580-11eb-1e20-85f296118996
samples = imcmc(rng, logtarget,  Vₓ, logp_vₓ, involution, x0; n = 100000)

# ╔═╡ e435a728-7586-11eb-1f1c-e5ff17b67e31
unpact(samples) = [[sample[i] for sample in samples] for i = 1:2]

# ╔═╡ d5607b06-7586-11eb-313e-d5acfad97d7d
Plots.histogram2d(unpact(samples)..., nbins = 100)

# ╔═╡ Cell order:
# ╠═6e9dbc6c-757f-11eb-0a43-1b6a3f01f1aa
# ╠═80b0b83e-757f-11eb-1512-4b62350fb830
# ╠═8374fde4-757f-11eb-2e1c-abe5ecf25d02
# ╠═86ae4f9e-757f-11eb-07fd-9daa27aae41a
# ╠═30e3b7d8-7580-11eb-26e4-4913ed8ba40c
# ╠═36475d28-7581-11eb-20a2-55d445b832f3
# ╠═89e816f4-757f-11eb-06b3-1d1094d9a25b
# ╠═bf704d84-757f-11eb-26a1-cd7a733b6ac0
# ╠═3884d3b4-7580-11eb-3549-8bbbdd4c0ff7
# ╠═0ab7717a-7581-11eb-3dc8-35536853f805
# ╠═1aa926e6-7581-11eb-08ed-2911a3dfb0a8
# ╠═d1389aaa-7580-11eb-1338-af09627a4cda
# ╠═4b235bfe-7581-11eb-2a19-092b27730c90
# ╠═4029729a-7581-11eb-2639-51a448011a48
# ╠═7519366c-7580-11eb-3b9e-edc42831b839
# ╠═cd7804ea-7581-11eb-20b0-8de7d6371441
# ╠═909b419a-7581-11eb-2381-93c6f4ee6f38
# ╠═7e20ee3a-7580-11eb-3acf-5906a2c6374a
# ╠═5e4a80c4-7582-11eb-0694-2d1d9418b6b6
# ╠═76dca6f4-7586-11eb-0b9e-f78d1b47240c
# ╠═39e5449e-75aa-11eb-0831-1986962d0bee
# ╠═662c766e-7582-11eb-3150-513857e0213f
# ╠═9c92e826-7582-11eb-34a2-979d09caac22
# ╠═925c225c-7580-11eb-1e20-85f296118996
# ╠═e435a728-7586-11eb-1f1c-e5ff17b67e31
# ╠═d5607b06-7586-11eb-313e-d5acfad97d7d
