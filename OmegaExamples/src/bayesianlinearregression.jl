### A Pluto.jl notebook ###
# v0.19.11

using Markdown
using InteractiveUtils

# ╔═╡ 22a37ff4-3ae0-4338-86a2-3310b7773c1d
begin
    import Pkg
    # activate the shared project environment|
    Pkg.activate(Base.current_project())
    using Omega
	using Distributions
	using UnicodePlots
	using ForwardDiff
	using AdvancedHMC
	using Random: MersenneTwister
	using Plots
	using Revise
end

# ╔═╡ 6b2fe98e-76cf-11eb-39f8-9ff52d23e688
md"# Bayesian Linear Regression"

# ╔═╡ a2fb35f7-8c48-4e70-aff8-d8ee431aa872
md"Bayesian linear regression is a method to infer the parameters of linear model between two variables.  The \"Bayesian\" part of Bayesian linear regression means means that it treats the problem of finding these parameters as one of Bayesian inference."

# ╔═╡ 588dba84-a094-442b-91e3-68bfe548c110
gr()

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
m = 4.3

# ╔═╡ 0af4f988-76cf-11eb-012e-cf2182fa826b
c = 1.2

# ╔═╡ ff7d2e7c-76ce-11eb-249b-cbf84db4fe9b
linear_model(x, m, c) = m * x + c

# ╔═╡ 2288d0d2-76d0-11eb-29e9-21a78bc370e8
obs_model(x) = linear_model(x, m, c) + randn(rng) * 0.1;

# ╔═╡ 107a8c36-76cf-11eb-1adf-43f11a9a4204
ys = obs_model.(xs);

# ╔═╡ 1dc0257e-76cf-11eb-3fa5-377113ba0a49
scatter(xs, ys)

# ╔═╡ 61f89028-76cf-11eb-1813-9179e3467f47
md"## Probabilistic Model"

# ╔═╡ 79cd6e26-76cf-11eb-1930-399093becba8
M = @~ Normal(0, 5);

# ╔═╡ a9765e1c-76cf-11eb-3495-79aa95e21afd
C = @~ Normal(0, 5);

# ╔═╡ 7fce6a74-8b68-45ce-bb9c-a4c4e39fcc1e
struct ϵ end

# ╔═╡ b2cc4db2-76cf-11eb-390d-f151ff4b939d
Y_class(i, ω) = 
	linear_model(xs[i], M(ω), C(ω)) + (ϵ ∘ i ~ Normal(0, 0.1))(ω);

# ╔═╡ 800049e2-f44b-4839-a2ae-7fb0beeb5c0e
Y⃗ = Mv(1:N, Y_class)

# ╔═╡ fa8b5cc2-7728-11eb-24b3-5db1bd7d0255
scatter(xs, randsample(Y⃗))

# ╔═╡ b3c0e452-fff8-419e-945c-27e2d21c9fe3
evidence = pw(==, Y⃗, ys)

# ╔═╡ 3d5b3ac2-bf70-4710-9c97-1cbef7be4c11
joint_posterior = @joint(M, C) |ᶜ evidence

# ╔═╡ 8de8283b-39b0-441b-9baa-0e64d0ffdf50
md"## Solving Manually"

# ╔═╡ ced95204-9f8b-41f4-b5b6-3cc161d274ff
md"Conditional on `Y⃗` being equal to `ys`, some other things are true."

# ╔═╡ f4f6f0b1-4da7-41da-b0b5-22f27c7c82dd
"""
Propagate the fact that Given that we know that Y⃗ is equal to ys, 

Returns:
`ω`: mapping of exogenous random variables to values consistent with inputs
"""
function propagate(rng, ::typeof(Y⃗), ys)
	# We know that the value of Yᵢ is ys[i]
	map(iy -> propagate(rng, Y_class, iy[1], iy[2]), enumerate(ys))
end

# ╔═╡ 823bb374-6e3a-4560-9d07-98a5c43567f6
md"Conditional on `Y⃗_i` being equal to `ys[i]`  some other things are true."

# ╔═╡ 4f1aada0-54a7-4640-930e-43a2c3c4ed89
function propagate(rng, ::typeof(Y_class), i, y_, m_, c_)
	# M(ω), C(ω)
	ϵ_ = y_ - linear_model(xs[i], m_, c_)
	propagate(rng, (ϵ ∘ i) ~ Normal(0, 0.1), ϵ_)
end

# ╔═╡ 87fd6e6b-0a0c-4383-84e4-f33fb0254092
function propagate(rng, class::Member{<:Normal, I}, y) where {I}
	x = class.class
	(class.id ~ StdNormal{Float64}()) => (y - x.μ) / x.σ
end

# ╔═╡ 3ae42e17-9b17-452c-9c5d-eca6e5a17441
rng_ = MersenneTwister(0)

# ╔═╡ bf6755f0-5294-43ca-8212-d823fbbd6b6e
function ℓπ_noise(θ)
	m_, c_ = θ
	map(iy -> propagate(rng_, Y⃗, iy[1], iy[2], m_, c_), enumerate(ys))
end

# ╔═╡ b02f5a68-ef9c-4267-8415-9f845ff6f8c9
"Posterior density function"
function ℓπ(θ)
	m_, c_ = θ
	mexp = propagate(nothing, M, m_)
	mc = propagate(nothing, C, c_)
	exos = [mexp, mc]
	logenergyexo(exos) + logenergyexo(ℓπ_noise(θ))
end

# ╔═╡ 69060e14-3799-44f4-b3dc-d66b8bd0e4b7
md"Let's plot the log posterior distribution"

# ╔═╡ 98bdeffa-fce2-4a8d-8584-35da6a49e5f0
plot(x-> ℓπ([x, 1.0]), -40, 20) 

# ╔═╡ 75ae3d34-bb44-4592-9755-9e52a03fb976
ℓπ([1.0, 1.0])

# ╔═╡ 0f5a6659-c32c-40e9-89e5-3b5a8b9e4fd0
D = N

# ╔═╡ 666d0e37-9063-4909-a757-da60b1a3eceb
# Choose parameter dimensionality and initial parameter value
initial_θ = rand(D)

# ╔═╡ ef90178d-c231-4836-aefe-f592adfbaaa0
# Set the number of samples to draw and warmup iterations
n_samples, n_adapts = 1_000, 1_000

# ╔═╡ 78a54e59-2d3b-4236-8ef1-5e28673dd896
# Define a Hamiltonian system
metric = DiagEuclideanMetric(D)

# ╔═╡ ea40d946-b1e4-466d-9fbd-9045fee0a5e0
hamiltonian = Hamiltonian(metric, ℓπ, ForwardDiff)

# ╔═╡ 7ddac11a-532a-4aa9-8df1-72744218b27a
# Define a leapfrog solver, with initial step size chosen heuristically
initial_ϵ = find_good_stepsize(hamiltonian, initial_θ)

# ╔═╡ 3482754a-945c-4c24-9d77-7dcfe0ff2ed8
integrator = Leapfrog(initial_ϵ)

# ╔═╡ 70268618-c65d-4655-8108-2601f3dffb1e
# Define an HMC sampler, with the following components
#   - multinomial sampling scheme,
#   - generalised No-U-Turn criteria, and
#   - windowed adaption for step-size and diagonal mass matrix
proposal = NUTS{MultinomialTS, GeneralisedNoUTurn}(integrator)

# ╔═╡ d70a6d4a-d6c7-4428-8f50-5cf623f77612
adaptor = StanHMCAdaptor(MassMatrixAdaptor(metric), StepSizeAdaptor(0.8, integrator))

# ╔═╡ 79fbbe2c-d66e-4ff8-b3da-0164eac10072
# Run the sampler to draw samples from the specified Gaussian, where
#   - `samples` will store the samples
#   - `stats` will store diagnostic statistics for each sample
# samples, stats = sample(hamiltonian, proposal, initial_θ, n_samples, adaptor, n_adapts; progress=true)

# ╔═╡ aa781fbe-76d0-11eb-387a-3dc1cbf700f8
# samples = randsample(joint_posterior |ᶜ evidence, 1000; alg = MH) 

# ╔═╡ 6cb60e40-0b72-4605-98e6-72a525ae0368
m_samples = first.(samples)

# ╔═╡ fb468913-165b-4f4e-bccc-096c268672c9
c_samples = (x->x[2]).(samples)

# ╔═╡ f7efb0d0-76d1-11eb-3440-47df94aeb74e
Plots.histogram(m_samples)

# ╔═╡ Cell order:
# ╟─6b2fe98e-76cf-11eb-39f8-9ff52d23e688
# ╟─a2fb35f7-8c48-4e70-aff8-d8ee431aa872
# ╠═22a37ff4-3ae0-4338-86a2-3310b7773c1d
# ╠═588dba84-a094-442b-91e3-68bfe548c110
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
# ╠═b3c0e452-fff8-419e-945c-27e2d21c9fe3
# ╠═3d5b3ac2-bf70-4710-9c97-1cbef7be4c11
# ╟─8de8283b-39b0-441b-9baa-0e64d0ffdf50
# ╟─ced95204-9f8b-41f4-b5b6-3cc161d274ff
# ╠═f4f6f0b1-4da7-41da-b0b5-22f27c7c82dd
# ╟─823bb374-6e3a-4560-9d07-98a5c43567f6
# ╠═4f1aada0-54a7-4640-930e-43a2c3c4ed89
# ╠═87fd6e6b-0a0c-4383-84e4-f33fb0254092
# ╠═3ae42e17-9b17-452c-9c5d-eca6e5a17441
# ╠═bf6755f0-5294-43ca-8212-d823fbbd6b6e
# ╠═b02f5a68-ef9c-4267-8415-9f845ff6f8c9
# ╠═69060e14-3799-44f4-b3dc-d66b8bd0e4b7
# ╠═98bdeffa-fce2-4a8d-8584-35da6a49e5f0
# ╠═75ae3d34-bb44-4592-9755-9e52a03fb976
# ╠═0f5a6659-c32c-40e9-89e5-3b5a8b9e4fd0
# ╠═666d0e37-9063-4909-a757-da60b1a3eceb
# ╠═ef90178d-c231-4836-aefe-f592adfbaaa0
# ╠═78a54e59-2d3b-4236-8ef1-5e28673dd896
# ╠═ea40d946-b1e4-466d-9fbd-9045fee0a5e0
# ╠═7ddac11a-532a-4aa9-8df1-72744218b27a
# ╠═3482754a-945c-4c24-9d77-7dcfe0ff2ed8
# ╠═70268618-c65d-4655-8108-2601f3dffb1e
# ╠═d70a6d4a-d6c7-4428-8f50-5cf623f77612
# ╠═79fbbe2c-d66e-4ff8-b3da-0164eac10072
# ╠═aa781fbe-76d0-11eb-387a-3dc1cbf700f8
# ╠═6cb60e40-0b72-4605-98e6-72a525ae0368
# ╠═fb468913-165b-4f4e-bccc-096c268672c9
# ╠═f7efb0d0-76d1-11eb-3440-47df94aeb74e
