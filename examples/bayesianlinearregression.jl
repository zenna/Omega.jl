### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 4addebb8-772e-11eb-0c48-1f597189a981
using Revise

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
plate(i, ω) = linear_model(xs[i], M(ω), C(ω)) + ((i, 1) ~ Normal(0, 0.1))(ω);

# ╔═╡ cf9ad9cc-776c-11eb-3d4e-4f32b65eb6b2
plate(i, ω, m_, c_) = linear_model(xs[i], m_, c_) + ((i, 1) ~ Normal(0, 0.1))(ω);

# ╔═╡ 3fea6676-7735-11eb-3947-b77b2def96dc
Y = (1:N) .~ plate  # FIXME: This is not correct notation

# ╔═╡ 945fbdf4-776d-11eb-1bc9-8d273ec39b0b


# ╔═╡ 98baf47a-7724-11eb-2cd8-c36d03a11db2
obs(ω) = [y(ω) for y in Y]

# ╔═╡ fa8b5cc2-7728-11eb-24b3-5db1bd7d0255
UnicodePlots.scatterplot(xs, randsample(obs))

# ╔═╡ c32b2f96-76d0-11eb-3f9c-e33cc3a1a7e7
nsamples = 1000

# ╔═╡ aa781fbe-76d0-11eb-387a-3dc1cbf700f8
samples = rand((M, C) | Y == ys, nsamples; alg = HMC) 

# ╔═╡ f7efb0d0-76d1-11eb-3440-47df94aeb74e
UnicodePlots.scatterplot(xs, samples)

# ╔═╡ 19bb9822-7734-11eb-1170-b1eaab345ba5


# ╔═╡ Cell order:
# ╠═6b2fe98e-76cf-11eb-39f8-9ff52d23e688
# ╠═4addebb8-772e-11eb-0c48-1f597189a981
# ╠═9ef4a008-76ce-11eb-3550-0f72ff35976d
# ╠═ef39a4d2-76ce-11eb-16a2-a775469288f9
# ╠═b5f202a0-76ce-11eb-23e8-c5036fc43538
# ╠═a44b4d1c-76cf-11eb-2cae-69ac6a56ca5a
# ╠═b583b52a-76ce-11eb-088b-dbeb7791729f
# ╠═ee2f8174-76ce-11eb-2c74-298d6072afee
# ╠═d10a9c5a-76ce-11eb-0ece-bd1b6e946fe0
# ╠═d83b52d0-76ce-11eb-0d3f-d1ddd64d6e08
# ╠═e61b99a8-76ce-11eb-2d0e-1f8d2f31eba4
# ╠═0af4f988-76cf-11eb-012e-cf2182fa826b
# ╠═ff7d2e7c-76ce-11eb-249b-cbf84db4fe9b
# ╠═2288d0d2-76d0-11eb-29e9-21a78bc370e8
# ╠═107a8c36-76cf-11eb-1adf-43f11a9a4204
# ╠═1dc0257e-76cf-11eb-3fa5-377113ba0a49
# ╠═61f89028-76cf-11eb-1813-9179e3467f47
# ╠═79cd6e26-76cf-11eb-1930-399093becba8
# ╠═a9765e1c-76cf-11eb-3495-79aa95e21afd
# ╠═b2cc4db2-76cf-11eb-390d-f151ff4b939d
# ╠═3fea6676-7735-11eb-3947-b77b2def96dc
# ╠═cf9ad9cc-776c-11eb-3d4e-4f32b65eb6b2
# ╠═945fbdf4-776d-11eb-1bc9-8d273ec39b0b
# ╠═98baf47a-7724-11eb-2cd8-c36d03a11db2
# ╠═fa8b5cc2-7728-11eb-24b3-5db1bd7d0255
# ╠═c32b2f96-76d0-11eb-3f9c-e33cc3a1a7e7
# ╠═aa781fbe-76d0-11eb-387a-3dc1cbf700f8
# ╠═f7efb0d0-76d1-11eb-3440-47df94aeb74e
# ╠═19bb9822-7734-11eb-1170-b1eaab345ba5
