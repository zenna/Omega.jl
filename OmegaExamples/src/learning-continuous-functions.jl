### A Pluto.jl notebook ###
# v0.17.1

using Markdown
using InteractiveUtils

# ╔═╡ 7c022d50-7ec4-11ec-1fde-8be8fdb0f22f
begin
    import Pkg
    # activate the shared project environment
    Pkg.activate(Base.current_project())
    using Omega, Distributions, UnicodePlots, OmegaExamples
	using Images, Plots
end

# ╔═╡ 5180d0a3-f875-48aa-9a3a-84366b82528c
DiagNormal = OmegaExamples.DiagNormal

# ╔═╡ 41364972-8306-42ba-af47-b2fa0ff700d9
md"""
## Fitting curves with neural nets
First recall our exercise inferring an unknown curve using polynomials:
"""

# ╔═╡ 0ec4fac2-b5f1-46ae-924b-61332d2f17f2
obs_data = [(x = -4, y = 69.76636938284166),
	(x = -3, y = 36.63586217969598),
	(x = -2, y = 19.95244368751754),
	(x = -1, y = 4.819485497724985),
	(x = 0, y = 4.027631414787425),
	(x = 1, y = 3.755022418210824),
	(x = 2, y = 6.557548104903805),
	(x = 3, y = 23.922485493795072),
	(x = 4, y = 50.69924692420815)]

# ╔═╡ 1ee66ebe-c7f9-4719-85bf-9c1420a63c75
make_poly(as) = x -> sum(map(i -> as[i]*x^(i-1), 1:length(as)))

# ╔═╡ 8c4470f4-bda7-49cd-a123-887af6c1be53
coeffs = manynth(Normal(0, 2), 1:4)

# ╔═╡ 8379f87d-e0d6-4963-9753-ec910f06c783
order = @~ Categorical([0.25, 0.25, 0.25, 0.25])

# ╔═╡ 9b9c0f9f-7f0c-48c2-be27-0cb9dd5d2bef
f(ω) = make_poly(coeffs(ω)[order(ω) + 1])

# ╔═╡ 8f2b6e6d-d684-4b21-bc3d-d630dd93adb5
obs_fn(ω) = 
	all((d ~ Normal(obs_data[d].x, 0.1))(ω) == obs_data[d].y for d in 1:length(obs_data))

# ╔═╡ 25be045e-9015-4b7f-8902-3ce7d16b986d
post = (@joint order coeffs) |ᶜ obs_fn

# ╔═╡ 5e9b1b60-1330-4e02-a311-996ab50892b4
function post_fn_samples(rng)
	ps = Float64[]
	for x in rng
		as = randsample(post, 1, alg = MH)
		push!(ps, make_poly(as.coeffs[1:as.order])(x))
	end
end

# ╔═╡ bee4722f-5571-40ef-a0aa-17a922db8791
lineplot(-5:0.1:5, post_fn_samples(-5:0.1:5))

# ╔═╡ a7565b34-6eb8-4efe-b515-8c6fd4104af2
md"""
Another approach to this curve fitting problem is to choose a family of functions that we think is flexible enough to capture any curve we might encounter. One possibility is to simply fix the order of the polynomial to be a high number – try fixing the order to 3 in the above example.

An alternative is to construct a class of functions by composing matrix multiplication with simple non-linearities. Functions constructed in this way are called _artificial neural nets_. Let’s explore learning with this class of functions:
"""

# ╔═╡ a874cb34-93f8-462e-85a5-8ad00d90c536
dm = 10

# ╔═╡ de510286-7356-4985-ba77-752e2b654408
σ(z) = one(z) / (one(z) + exp(-z))

# ╔═╡ e327abe3-6f77-49f6-9e1b-508966ce36af
make_fn(m1, m2, b1) = x -> m2 * σ.(m1 * x .+ b1)

# ╔═╡ c91ad23a-0d26-422a-a949-5369ffc8894c
m1(i, ω) = transpose(((@uid, i) ~ DiagNormal(zeros(dm), ones(dm)))(ω))

# ╔═╡ ece732ec-df15-41ab-84b3-8cb8072286d8
b1(i, ω) = ((@uid, i) ~ DiagNormal(zeros(dm), ones(dm)))(ω)

# ╔═╡ 29f10d97-9a38-4f1a-bf2d-de5a6f29a035
m2(i, ω) = ((@uid, i) ~ DiagNormal(zeros(dm), ones(dm)))(ω)

# ╔═╡ 826c50d3-614b-4154-bcdb-72035cd28dbc
function posterior(ω, data)
	for (i, d) in enumerate(data)
		cond!(ω, (i ~ Normal(d.x, 0.1))(ω) ==ₛ d.y)
	end
	return (m1 = (@~ m1)(ω), m2 = (@~ m2)(ω), b1 = (@~ b1)(ω))
end

# ╔═╡ f99d7a23-9ab9-4ba1-b9c3-48a01503b8d8
post_func_samples(xs) = 
	map(x -> make_fn(randsample(ω -> posterior(ω, obs_data), 1, alg = MH)...)(x), xs)

# ╔═╡ d2573159-50f7-4a9d-a9ec-74b3ec7cf0cc
lineplot(-5:0.1:5, post_func_samples(-5:0.1:5))

# ╔═╡ 386f2036-2e33-4141-a5ee-cbd8e1f9dd63
md"""
Just as the order of a polynomial affects the complexity of functions that can result, the size and number of the _hidden layers_ affect the complexity of functions for neural nets. Try changing `dm` (the size of the single hidden layer) in the above example – pay particular attention to how the model generalizes out of the [-4,4] training interval.

Neural nets are a very useful class of functions because they are very flexible, but can still (usually) be learned by maximum likelihood inference.
"""

# ╔═╡ 9b3d1811-e693-4784-a6aa-d1a4fe6884a9
md"""
### Gaussian processes
Given the importance of the hidden dimension `hd`, you might be curious what happens if we let it get really big. In this case `y` is the sum of a very large number of terms. Due to the [central limit theorem](https://en.wikipedia.org/wiki/Central_limit_theorem), and assuming uncertainty over the weight matrices, this sum converges on a Gaussian as the width `hd` goes to infinity. That is, infinitely “wide” neural nets yield a model where `f(x)` is Gaussian distributed for each `x`, and further (it turns out) the covariance among different `x`s is also Gaussian. This kind of model is called a [_Gaussian Process_](https://en.wikipedia.org/wiki/Gaussian_process).

## Deep generative models
So far in this chapter, we have considered _supervised_ learning, where we are trying to learn the dependence of `y` on `x`. This is a special case because we only care about predicting `y`. Neural nets are particularly good at this kind of problem. However, many interesting problems are _unsupervised_: we get a bunch of examples and want to understand them by capturing their distribution.

Having shown that we can put an unknown function in our supervised model, nothing prevents us from putting one anywhere in a generative model! Here we learn an unsupervised model of x,y pairs, which are generated from a latent random choice passed through a (learned) function.
"""

# ╔═╡ 1196a3ca-0a81-4ac7-a04b-b4e3cd9d1dc3
hd = 10

# ╔═╡ 888e27cd-1eb8-4714-abc2-76a06deda4d2
ld = 2

# ╔═╡ c81017d1-ec7a-46f1-aa1f-11cc41acfd51
out_sig = ones(2)

# ╔═╡ 4b1fc967-23f3-4cea-9dc4-918895b1b67e
m1_(i, ω) = 
	reduce(hcat, map(l -> ((@uid, i, l) ~ DiagNormal(zeros(hd), ones(hd)))(ω), 1:ld))

# ╔═╡ 85fbd149-b7e6-4884-b7a8-4530d03327e9
b1_(i, ω) = ((@uid, i) ~ DiagNormal(zeros(hd), ones(hd)))(ω)

# ╔═╡ 1e393dba-dd29-405d-a380-33b3cdb5ef33
m2_(i, ω) = 
	reduce(hcat, map(l -> ((@uid, i, l) ~ DiagNormal(zeros(hd), ones(hd)))(ω), 1:ld))'

# ╔═╡ 24b7c959-e99c-4e22-86c4-e6fd31a2e51b
f(i, ω) = make_fn(m1_(i, ω), m2_(i, ω), b1_(i, ω))

# ╔═╡ 3340e2c7-91c1-4d26-bdac-e1fdd930f178
sample_XY(i, ω) = randsample(i~f)((i~DiagNormal(zeros(ld), ones(ld)))(ω))

# ╔═╡ 0b35176c-a6c2-4ce7-a604-bfb962aaa1ef
function post_unsupervised(ω, data)
	means = manynth(sample_XY, 1:length(data))(ω)
	for (i, d) in enumerate(data)
		cond!(ω, ((@uid, i)~ DiagNormal(means[i], out_sig))(ω) ==ₛ [d.x, d.y])
	end
	return means
end

# ╔═╡ 014bbf7a-9651-4ba9-a1d4-aec8b544660c
scatterplot(map(o -> o.x, obs_data), map(o -> o.y, obs_data), marker = :xcross)

# ╔═╡ 88feb759-b2d1-4cba-9fc5-52d8a48f42b6
samples_unsupervised = randsample(ω -> post_unsupervised(ω, obs_data), 1, alg = MH)

# ╔═╡ 457d9495-6b7c-4851-8bf8-d586ee3aaf54
scatterplot(map(o -> o.x, samples_unsupervised), map(o -> o.y, samples_unsupervised), marker = :xcross)

# ╔═╡ 5ca6ef68-cff7-48a2-8173-02eb26202c2e
md"""
Models of this sort are often called _deep generative models_ because the (here not very) deep neural net is doing a large amount of work to generate complex observations.

Notice that while this model reconstructs the data well, the posterior predictive looks like noise. That is, this model _over-fits_ the data. To ameliorate over-fitting, we might try to limit the expressive capacity of the model. For instance by reducing the latent dimension for z (i.e. `ld`) to $1$, since we know that the data actually lie near a one-dimensional subspace. (Try it!) However that model usually simply over-fits in a more constrained way.

Here, we instead increase the data (by a lot) with the flexible model (warning, this takes much longer to run):
"""

# ╔═╡ 620c8198-7fe1-4352-a277-5199a27efe3d
obs_data_new = map(x -> (x = x, y = x*x), -4:0.1:4)

# ╔═╡ 0e317d8b-73f5-46f6-a084-79a631fdb495
samples_unsupervised_new = 
	randsample(ω -> post_unsupervised(ω, obs_data_new), 1, alg = MH)

# ╔═╡ a129aef2-6091-4e3c-963d-937d585152fc
scatterplot(map(o -> o.x, samples_unsupervised_new), map(o -> o.y, samples_unsupervised_new), marker = :xcross)

# ╔═╡ b630a294-e0b3-41a0-bcc1-814facc019fb
md"""
Notice that we still fit the data reasonably well, but now we generalize a bit more usefully. With even more data, perhaps we’d capture the distribution even better? But the slowdown in inference time would be intolerable….
"""

# ╔═╡ 7674251f-978b-4b48-8c38-8c6c2d88bb1b
# Minibatches - how to?

# ╔═╡ Cell order:
# ╠═7c022d50-7ec4-11ec-1fde-8be8fdb0f22f
# ╠═5180d0a3-f875-48aa-9a3a-84366b82528c
# ╟─41364972-8306-42ba-af47-b2fa0ff700d9
# ╠═0ec4fac2-b5f1-46ae-924b-61332d2f17f2
# ╠═1ee66ebe-c7f9-4719-85bf-9c1420a63c75
# ╠═8c4470f4-bda7-49cd-a123-887af6c1be53
# ╠═8379f87d-e0d6-4963-9753-ec910f06c783
# ╠═9b9c0f9f-7f0c-48c2-be27-0cb9dd5d2bef
# ╠═8f2b6e6d-d684-4b21-bc3d-d630dd93adb5
# ╠═25be045e-9015-4b7f-8902-3ce7d16b986d
# ╠═5e9b1b60-1330-4e02-a311-996ab50892b4
# ╠═bee4722f-5571-40ef-a0aa-17a922db8791
# ╟─a7565b34-6eb8-4efe-b515-8c6fd4104af2
# ╠═a874cb34-93f8-462e-85a5-8ad00d90c536
# ╠═de510286-7356-4985-ba77-752e2b654408
# ╠═e327abe3-6f77-49f6-9e1b-508966ce36af
# ╠═c91ad23a-0d26-422a-a949-5369ffc8894c
# ╠═ece732ec-df15-41ab-84b3-8cb8072286d8
# ╠═29f10d97-9a38-4f1a-bf2d-de5a6f29a035
# ╠═826c50d3-614b-4154-bcdb-72035cd28dbc
# ╠═f99d7a23-9ab9-4ba1-b9c3-48a01503b8d8
# ╠═d2573159-50f7-4a9d-a9ec-74b3ec7cf0cc
# ╟─386f2036-2e33-4141-a5ee-cbd8e1f9dd63
# ╟─9b3d1811-e693-4784-a6aa-d1a4fe6884a9
# ╠═1196a3ca-0a81-4ac7-a04b-b4e3cd9d1dc3
# ╠═888e27cd-1eb8-4714-abc2-76a06deda4d2
# ╠═c81017d1-ec7a-46f1-aa1f-11cc41acfd51
# ╠═4b1fc967-23f3-4cea-9dc4-918895b1b67e
# ╠═85fbd149-b7e6-4884-b7a8-4530d03327e9
# ╠═1e393dba-dd29-405d-a380-33b3cdb5ef33
# ╠═24b7c959-e99c-4e22-86c4-e6fd31a2e51b
# ╠═3340e2c7-91c1-4d26-bdac-e1fdd930f178
# ╠═0b35176c-a6c2-4ce7-a604-bfb962aaa1ef
# ╠═014bbf7a-9651-4ba9-a1d4-aec8b544660c
# ╠═88feb759-b2d1-4cba-9fc5-52d8a48f42b6
# ╠═457d9495-6b7c-4851-8bf8-d586ee3aaf54
# ╟─5ca6ef68-cff7-48a2-8173-02eb26202c2e
# ╠═620c8198-7fe1-4352-a277-5199a27efe3d
# ╠═0e317d8b-73f5-46f6-a084-79a631fdb495
# ╠═a129aef2-6091-4e3c-963d-937d585152fc
# ╟─b630a294-e0b3-41a0-bcc1-814facc019fb
# ╠═7674251f-978b-4b48-8c38-8c6c2d88bb1b
