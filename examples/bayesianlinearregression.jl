### A Pluto.jl notebook ###
# v0.14.8

using Markdown
using InteractiveUtils

# ╔═╡ 7be85a71-3636-4919-99fb-9b688f085fb8
using Revise

# ╔═╡ 9ef4a008-76ce-11eb-3550-0f72ff35976d
using Omega

# ╔═╡ ef39a4d2-76ce-11eb-16a2-a775469288f9
using Random: MersenneTwister

# ╔═╡ a44b4d1c-76cf-11eb-2cae-69ac6a56ca5a
using Distributions

# ╔═╡ 6209b05f-b48f-45b5-9ee0-5b3447e26e06
using SoftPredicates

# ╔═╡ 6b2fe98e-76cf-11eb-39f8-9ff52d23e688
md"# Bayesian Linear Regression"

# ╔═╡ a2fb35f7-8c48-4e70-aff8-d8ee431aa872
md"Bayesian linear regression is a method to infer the parameters of linear model between two variables.  The \"Bayesian\" part of Bayesian linear regression means means that it treats the problem of finding these parameters as one of Bayesian inference."

# ╔═╡ b5f202a0-76ce-11eb-23e8-c5036fc43538
import UnicodePlots

# ╔═╡ b583b52a-76ce-11eb-088b-dbeb7791729f
md"""## Data
First, let's create some fake data"""

# ╔═╡ ee2f8174-76ce-11eb-2c74-298d6072afee
rng = MersenneTwister(0);

# ╔═╡ d10a9c5a-76ce-11eb-0ece-bd1b6e946fe0
N = 100;

# ╔═╡ d83b52d0-76ce-11eb-0d3f-d1ddd64d6e08
xs = rand(rng, N)

# ╔═╡ e61b99a8-76ce-11eb-2d0e-1f8d2f31eba4
m = 0.8

# ╔═╡ 0af4f988-76cf-11eb-012e-cf2182fa826b
c = 1.2

# ╔═╡ ff7d2e7c-76ce-11eb-249b-cbf84db4fe9b
linear_model(x, m, c) = m * x + c

# ╔═╡ 2288d0d2-76d0-11eb-29e9-21a78bc370e8
obs_model(x) = linear_model(x, m, c) + randn(rng) * 0.1;

# ╔═╡ 107a8c36-76cf-11eb-1adf-43f11a9a4204
ys = obs_model.(xs);

# ╔═╡ 1dc0257e-76cf-11eb-3fa5-377113ba0a49
UnicodePlots.scatterplot(xs, ys)

# ╔═╡ 61f89028-76cf-11eb-1813-9179e3467f47
md"## Probabilistic Model"

# ╔═╡ 79cd6e26-76cf-11eb-1930-399093becba8
M = 1 ~ Normal(0, 1);

# ╔═╡ a9765e1c-76cf-11eb-3495-79aa95e21afd
C = 2 ~ Normal(0, 1);

# ╔═╡ b2cc4db2-76cf-11eb-390d-f151ff4b939d
Y_class(i, ω) = linear_model(xs[i], M(ω), C(ω)) + ((i, 1) ~ Normal(0, 0.1))(ω);

# ╔═╡ 800049e2-f44b-4839-a2ae-7fb0beeb5c0e
Y⃗ = Mv(1:N, Y_class)  # FIXME: This is not correct notation

# ╔═╡ cf9ad9cc-776c-11eb-3d4e-4f32b65eb6b2
plate(i, ω, m_, c_) = linear_model(xs[i], m_, c_) + ((i, 1) ~ Normal(0, 0.1))(ω);

# ╔═╡ fa8b5cc2-7728-11eb-24b3-5db1bd7d0255
UnicodePlots.scatterplot(xs, randsample(Y⃗))

# ╔═╡ c32b2f96-76d0-11eb-3f9c-e33cc3a1a7e7
nsamples = 1000

# ╔═╡ b3c0e452-fff8-419e-945c-27e2d21c9fe3
 Evidence = Y⃗ ==ₚ ys

# ╔═╡ 3efb0dfe-079b-4fa2-8069-065d66b5f1b1
Evidenceₛ = pw(==ₛ, Y⃗, ys)

# ╔═╡ e8f55ded-038b-4b3a-a883-86139c40452c
randsample(Evidenceₛ)

# ╔═╡ f88f7939-c976-4ede-ae61-bc743cea984c
Y⃗_posterior = Y⃗ |ᶜ Evidenceₛ

# ╔═╡ 90e199ed-56b8-451d-81ec-885b6db97cc3
ω = defω()

# ╔═╡ a2c4cce9-cd16-4d79-b878-8ba36f1d3d00
(Omega.OmegaCore.condvar(Y⃗_posterior, SoftPredicates.DualSoftBool{Float64}))(ω)

# ╔═╡ aa781fbe-76d0-11eb-387a-3dc1cbf700f8
samples = rand((M, C) |ᶜ Evidence, nsamples; alg = HMC) 

# ╔═╡ f7efb0d0-76d1-11eb-3440-47df94aeb74e
UnicodePlots.scatterplot(xs, samples)

# ╔═╡ 19bb9822-7734-11eb-1170-b1eaab345ba5


# ╔═╡ Cell order:
# ╟─6b2fe98e-76cf-11eb-39f8-9ff52d23e688
# ╟─a2fb35f7-8c48-4e70-aff8-d8ee431aa872
# ╠═7be85a71-3636-4919-99fb-9b688f085fb8
# ╠═9ef4a008-76ce-11eb-3550-0f72ff35976d
# ╠═ef39a4d2-76ce-11eb-16a2-a775469288f9
# ╠═b5f202a0-76ce-11eb-23e8-c5036fc43538
# ╠═a44b4d1c-76cf-11eb-2cae-69ac6a56ca5a
# ╠═6209b05f-b48f-45b5-9ee0-5b3447e26e06
# ╟─b583b52a-76ce-11eb-088b-dbeb7791729f
# ╠═ee2f8174-76ce-11eb-2c74-298d6072afee
# ╠═d10a9c5a-76ce-11eb-0ece-bd1b6e946fe0
# ╠═d83b52d0-76ce-11eb-0d3f-d1ddd64d6e08
# ╠═e61b99a8-76ce-11eb-2d0e-1f8d2f31eba4
# ╠═0af4f988-76cf-11eb-012e-cf2182fa826b
# ╠═ff7d2e7c-76ce-11eb-249b-cbf84db4fe9b
# ╠═2288d0d2-76d0-11eb-29e9-21a78bc370e8
# ╠═107a8c36-76cf-11eb-1adf-43f11a9a4204
# ╠═1dc0257e-76cf-11eb-3fa5-377113ba0a49
# ╟─61f89028-76cf-11eb-1813-9179e3467f47
# ╠═79cd6e26-76cf-11eb-1930-399093becba8
# ╠═a9765e1c-76cf-11eb-3495-79aa95e21afd
# ╠═b2cc4db2-76cf-11eb-390d-f151ff4b939d
# ╠═800049e2-f44b-4839-a2ae-7fb0beeb5c0e
# ╠═cf9ad9cc-776c-11eb-3d4e-4f32b65eb6b2
# ╠═fa8b5cc2-7728-11eb-24b3-5db1bd7d0255
# ╠═c32b2f96-76d0-11eb-3f9c-e33cc3a1a7e7
# ╠═b3c0e452-fff8-419e-945c-27e2d21c9fe3
# ╠═3efb0dfe-079b-4fa2-8069-065d66b5f1b1
# ╠═e8f55ded-038b-4b3a-a883-86139c40452c
# ╠═f88f7939-c976-4ede-ae61-bc743cea984c
# ╠═90e199ed-56b8-451d-81ec-885b6db97cc3
# ╠═a2c4cce9-cd16-4d79-b878-8ba36f1d3d00
# ╠═aa781fbe-76d0-11eb-387a-3dc1cbf700f8
# ╠═f7efb0d0-76d1-11eb-3440-47df94aeb74e
# ╠═19bb9822-7734-11eb-1170-b1eaab345ba5
