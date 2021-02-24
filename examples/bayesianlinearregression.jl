### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 9ef4a008-76ce-11eb-3550-0f72ff35976d
using Omega

# ╔═╡ ef39a4d2-76ce-11eb-16a2-a775469288f9
using Random: MersenneTwister

# ╔═╡ a44b4d1c-76cf-11eb-2cae-69ac6a56ca5a
using Distributions

# ╔═╡ 6b2fe98e-76cf-11eb-39f8-9ff52d23e688
md"# Bayesian Linear Regression"

# ╔═╡ b5f202a0-76ce-11eb-23e8-c5036fc43538
import UnicodePlots

# ╔═╡ 33ec996a-76d2-11eb-293b-0d083bf7a376


# ╔═╡ b583b52a-76ce-11eb-088b-dbeb7791729f
md"""## Data
First, let's create some fake data"""

# ╔═╡ ee2f8174-76ce-11eb-2c74-298d6072afee
rng = MersenneTwister(0);

# ╔═╡ d10a9c5a-76ce-11eb-0ece-bd1b6e946fe0
N = 1000;

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
M = 1 ~ Normal(0, 1) # FIXME: Do I want to ensure that 1 and 2 do not clash with 1 and 2 from other files?

# ╔═╡ a9765e1c-76cf-11eb-3495-79aa95e21afd
C = 2 ~ Normal(0, 1)

# ╔═╡ b2cc4db2-76cf-11eb-390d-f151ff4b939d
plate(i, ω) = linear_model(X[i], m(ω), c(ω)) + (i, 1) ~ Normal(0, 0.1) #FIXME: I'm not sure that (i, 1) is yet supported

# ╔═╡ 6df94c4a-76d0-11eb-1d4a-1db3ad148b40
Y = plate .. 1:N # FIXME: This is not correct notation

# ╔═╡ c32b2f96-76d0-11eb-3f9c-e33cc3a1a7e7
nsamples = 1000

# ╔═╡ aa781fbe-76d0-11eb-387a-3dc1cbf700f8
samples = rand((M, C) | Y == ys, nsamples; alg = HMC) 

# ╔═╡ f7efb0d0-76d1-11eb-3440-47df94aeb74e
UnicodePlots.scatterplot(xs, samples)

# ╔═╡ Cell order:
# ╟─6b2fe98e-76cf-11eb-39f8-9ff52d23e688
# ╠═9ef4a008-76ce-11eb-3550-0f72ff35976d
# ╠═ef39a4d2-76ce-11eb-16a2-a775469288f9
# ╠═b5f202a0-76ce-11eb-23e8-c5036fc43538
# ╠═a44b4d1c-76cf-11eb-2cae-69ac6a56ca5a
# ╠═33ec996a-76d2-11eb-293b-0d083bf7a376
# ╠═b583b52a-76ce-11eb-088b-dbeb7791729f
# ╠═ee2f8174-76ce-11eb-2c74-298d6072afee
# ╠═d10a9c5a-76ce-11eb-0ece-bd1b6e946fe0
# ╟─d83b52d0-76ce-11eb-0d3f-d1ddd64d6e08
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
# ╠═6df94c4a-76d0-11eb-1d4a-1db3ad148b40
# ╠═c32b2f96-76d0-11eb-3f9c-e33cc3a1a7e7
# ╠═aa781fbe-76d0-11eb-387a-3dc1cbf700f8
# ╠═f7efb0d0-76d1-11eb-3440-47df94aeb74e
