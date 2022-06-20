### A Pluto.jl notebook ###
# v0.19.8

using Markdown
using InteractiveUtils

# ╔═╡ 22a37ff4-3ae0-4338-86a2-3310b7773c1d
begin
    import Pkg
    # activate the shared project environment|
    Pkg.activate(Base.current_project())
    using Omega
	Pkg.add("Distributions")
	Pkg.instantiate()
	using Distributions
	using UnicodePlots
	using Random: MersenneTwister
end

# ╔═╡ 6b2fe98e-76cf-11eb-39f8-9ff52d23e688
md"# Bayesian Linear Regression"

# ╔═╡ a2fb35f7-8c48-4e70-aff8-d8ee431aa872
md"Bayesian linear regression is a method to infer the parameters of linear model between two variables.  The \"Bayesian\" part of Bayesian linear regression means means that it treats the problem of finding these parameters as one of Bayesian inference."

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
M = @~ Normal(0, 1);

# ╔═╡ a9765e1c-76cf-11eb-3495-79aa95e21afd
C = @~ Normal(0, 1);

# ╔═╡ 7fce6a74-8b68-45ce-bb9c-a4c4e39fcc1e
struct ϵ end

# ╔═╡ b2cc4db2-76cf-11eb-390d-f151ff4b939d
Y_class(i, ω) = linear_model(xs[i], M(ω), C(ω)) + (ϵ ∘ i ~ Normal(0, 0.1))(ω);

# ╔═╡ 800049e2-f44b-4839-a2ae-7fb0beeb5c0e
Y⃗ = Mv(1:N, Y_class)

# ╔═╡ fa8b5cc2-7728-11eb-24b3-5db1bd7d0255
UnicodePlots.scatterplot(xs, randsample(Y⃗))

# ╔═╡ cf09331c-c5cd-49f0-8ad5-eced9cb56d37
(ω = defω(); Y⃗(ω); ω)

# ╔═╡ b3c0e452-fff8-419e-945c-27e2d21c9fe3
evidence = pw(==, Y⃗, ys)

# ╔═╡ 3d5b3ac2-bf70-4710-9c97-1cbef7be4c11
joint_posterior = @joint(M, C) |ᶜ evidence

# ╔═╡ aa781fbe-76d0-11eb-387a-3dc1cbf700f8
samples = randsample(joint_posterior |ᶜ evidence, 1000; alg = MH) 

# ╔═╡ f7efb0d0-76d1-11eb-3440-47df94aeb74e
UnicodePlots.scatterplot(xs, samples)

# ╔═╡ Cell order:
# ╟─6b2fe98e-76cf-11eb-39f8-9ff52d23e688
# ╟─a2fb35f7-8c48-4e70-aff8-d8ee431aa872
# ╠═22a37ff4-3ae0-4338-86a2-3310b7773c1d
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
# ╠═7fce6a74-8b68-45ce-bb9c-a4c4e39fcc1e
# ╠═b2cc4db2-76cf-11eb-390d-f151ff4b939d
# ╠═800049e2-f44b-4839-a2ae-7fb0beeb5c0e
# ╠═fa8b5cc2-7728-11eb-24b3-5db1bd7d0255
# ╠═cf09331c-c5cd-49f0-8ad5-eced9cb56d37
# ╠═b3c0e452-fff8-419e-945c-27e2d21c9fe3
# ╠═3d5b3ac2-bf70-4710-9c97-1cbef7be4c11
# ╠═aa781fbe-76d0-11eb-387a-3dc1cbf700f8
# ╠═f7efb0d0-76d1-11eb-3440-47df94aeb74e
