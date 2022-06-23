### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 9c5d8972-7485-11eb-25f7-155fbbd40d98
using Revise

# ╔═╡ 2c24aaca-7483-11eb-05a9-6f847b7d09b7
using Distributions

# ╔═╡ 42bb4640-7483-11eb-0661-677c524c62b0
using Plots

# ╔═╡ eeb0be1c-7483-11eb-341f-b1996e9a53a6
using OmegaMH

# ╔═╡ 9d2f2714-749b-11eb-1403-e3a045df62ca
using ReplicaExchange

# ╔═╡ ebd11c9a-7484-11eb-2941-c78e3e22d260
using Random

# ╔═╡ 0464d3ec-7489-11eb-1081-d761307263db
using Pkg; Pkg.add("PyPlot")

# ╔═╡ 94d6f4e6-74ac-11eb-0871-a31b2df5526d
using PlutoUI

# ╔═╡ 128974e2-7483-11eb-03a0-15b2abc75d66
md"# MCMC Test"

# ╔═╡ 318e4a98-7483-11eb-1916-c9630ecf07e2
md"First, let's setup our target density"

# ╔═╡ 27ced392-7483-11eb-3d36-7b8277daadff
dist = MvNormal([0.0, 0.0], [1.0, 1.0])

# ╔═╡ 7e4e66ce-7483-11eb-238e-d15279086f3b
target_density(x, y) = pdf(dist, [x, y])

# ╔═╡ 9a7dc4f2-7483-11eb-36be-251be000793e
target_density(0.2, 0.4)

# ╔═╡ 68100d38-7483-11eb-07d5-45547ad45143
Plots.surface(-4:0.1:4, -4:0.1:4, target_density, c = :blues)

# ╔═╡ f744509a-7483-11eb-3168-9bff07e7b245
md"Now let's sample from the distribution using Metropolis Hastings";

# ╔═╡ 09fe4874-7484-11eb-28be-9f5df0586c87
state_init = rand(2)

# ╔═╡ 20537202-7484-11eb-1d70-a1bcbaa3c265
target_logdensity(state) = logpdf(dist, state);

# ╔═╡ 3b0ac92e-7484-11eb-2e90-cf94eb2e9731
num_samples = 100001;

# ╔═╡ 4343d3b0-7484-11eb-388b-576f50c83335
function propose_and_logratio(rng, state)
	prop_dist = MvNormal(state, [0.1, 0.1])
	sample = rand(rng, prop_dist)
	(sample, 0)
end

# ╔═╡ e84726c8-7484-11eb-1512-c5cee451507a
rng = Random.MersenneTwister(0)

# ╔═╡ f8e56030-7484-11eb-2bb6-afa2f952b085
samples = OmegaMH.mh(rng, target_logdensity, num_samples, state_init, propose_and_logratio)

# ╔═╡ 747691fe-7487-11eb-292e-2975ef75e7f0
Xs = [i[1] for i in samples]

# ╔═╡ 814cf4ae-7487-11eb-1b18-c11f124dd18a
Ys = [i[2] for i in samples]

# ╔═╡ ff22c6e2-7487-11eb-3bbe-db691feb921b
Plots.histogram2d(Xs, Ys, nbins = 100)

# ╔═╡ 22183a3e-7487-11eb-192c-4370f0b71496
md"Now let's create an example that breaks MH"

# ╔═╡ 30131820-7487-11eb-11de-9561b77139e8
dist_hard = MixtureModel([MvNormal([-2.0, -2.0], [0.5, 0.5]),
		                  MvNormal([2.0, 2.0], [1.5, 0.1])],
						[0.5, 0.5])

# ╔═╡ b9c69864-7487-11eb-3942-e146b6ae5ea4
Plots.surface(-4:0.1:4, -4:0.1:4, (x, y) -> pdf(dist_hard, [x, y]), c = :blues)

# ╔═╡ 1c2dedee-7489-11eb-3a2c-519ab256505f
state_init_hard = [-1.2, -1.3]

# ╔═╡ b0030bf6-74a0-11eb-14c8-4f09bcb0327c
target_density_hard(state) = pdf(dist_hard, state);

# ╔═╡ d51078da-7488-11eb-334f-c1a0ce33384c
target_logdensity_hard(state) = logpdf(dist_hard, state);

# ╔═╡ ff1e6132-7488-11eb-3a82-d1e9fa247b42
samples_hard = OmegaMH.mh(rng,
						  target_logdensity_hard,
						  num_samples,
						  state_init,
						  propose_and_logratio)

# ╔═╡ 519dc07e-7489-11eb-295b-3769fa285c29
Xs_hard = [i[1] for i in samples_hard]

# ╔═╡ 5a8e043c-7489-11eb-23a5-9ba3521900bd
Ys_hard = [i[2] for i in samples_hard]

# ╔═╡ 4d3c151c-7489-11eb-2352-65f743d197d0
Plots.histogram2d(Xs_hard, Ys_hard, nbins = 100)

# ╔═╡ dd7f08f4-748a-11eb-15ae-1f79ca5c1a0c
md"Unfortunately, this doesn;t work in this new space; the MCMC chain fails to jump from mode to mode"

# ╔═╡ 92926c20-749c-11eb-37f7-e7ec05a5ee41
# relax(density, temp) = state -> 1 - exp(- density(state)/temp)
relax(density, temp) = state -> density(state)^(1/temp)

# ╔═╡ 98c5076a-74a1-11eb-0f34-99ffa441dee6
logrelax(logdensity, temp) = state -> (1/temp) * logdensity(state)

# ╔═╡ d1910068-74a0-11eb-21e6-e1d2410c1646
target_density_hard_rlx = relax(target_density_hard, 2.0)

# ╔═╡ a2b3e42c-74a0-11eb-1678-7148d7776b6e
Plots.surface(-4:0.1:4, -4:0.1:4, (x, y) -> target_density_hard_rlx([x,y]), c = :blues)

# ╔═╡ cd57df24-74a2-11eb-166f-31b691e72e12
temps = [1.0, 2.0, 20.0, 200.0]

# ╔═╡ e5df8ac4-74a2-11eb-3a36-31d7ac95fba8
function simulate_n(rng, logenergy, state, samples_per_swap, i)
	OmegaMH.mh(rng,
			   logenergy,
			   samples_per_swap,
			   state,
			   propose_and_logratio)
end

# ╔═╡ b75ae81e-74a3-11eb-2ac0-efd1a5c21f21
simulate_1(temp, state, samples_per_swap) = 
	simulate_n(temp, state, samples_per_swap)[end]

# ╔═╡ e208a218-74a3-11eb-28ac-0dec5c478e15
function evaluate(temp, state)
	relaxed_logdensity = logrelax(target_logdensity_hard, temp)
	relaxed_logdensity(state)
end

# ╔═╡ ee2bb440-748a-11eb-046b-e5a4741ffe99
logenergys = [x -> evaluate(temp, x) for temp in temps]
samples_hard_wow = re!(rng, logenergys, 1, 10000, [deepcopy(state_init) for i = 1:length(temps)], [zeros(2) for i in 1:10000], simulate_n)#, simulate_1, evaluate)
# samples_hard_wow = re!(rng, logenergys, 1, 10000, [deepcopy(state_init) for i = 1:length(temps)], simulate_n, simulate_1, evaluate)

# ╔═╡ 59576824-74b3-11eb-1a98-d773404b49e0
unpack(s) = [i[1] for i in s], [i[2] for i in s]

# ╔═╡ b870ea20-74a4-11eb-2ab7-6972d5d2a105
Plots.histogram2d(unpack(samples_hard_wow)..., nbins = 100)

# ╔═╡ 25be5166-74a8-11eb-1255-bf738e624e97
Plots.contour(-4:0.1:4, -4:0.1:4, (x, y) -> target_density_hard_rlx([x,y]), c = :blues)

# ╔═╡ de1d4ab8-74a7-11eb-16a1-c728c0e288b8
function mcmc_dynamics(pdfs, traces, lbub, xrng = -4:0.1:4, yrng = -4:0.1:4)
	# plt = Plots.contoour(pdfs[1])
	plots = []
	for i = 1:length(pdfs)
		plt = Plots.contour(xrng, yrng,
							  (x, y) -> pdfs[i]([x, y]),
							   c = :blues,
							   aspect_ratio = 1.0)
		Xs = [j[1] for j in traces[i]]
	    Ys = [j[2] for j in traces[i]]
		plot!(plt, Xs[lbub], Ys[lbub])
			# , alpha = range(0.0; stop = 1.0, length = length(lbub)))
		push!(plots, plt)
	end
	Plots.plot(plots..., layour = (4, 1))
end

# ╔═╡ 745f702a-74a8-11eb-1ada-cf83599e0b17
pdfs = [relax(target_density_hard, temp) for temp in temps]

# ╔═╡ 0603ea0c-74ad-11eb-29ef-d58f5a17aba4
swap_every = 10

# ╔═╡ 0a36105a-74ad-11eb-27c8-ed6919e3c5c8
samples_per_swap = 10000

# ╔═╡ 17ace2ae-74ad-11eb-34be-3be5f9eb6f28
niters = swap_every * samples_per_swap

# ╔═╡ b82be6b2-74a8-11eb-1df2-9d26ac88ccbb
traces = re_all!(rng, temps, swap_every, samples_per_swap, [deepcopy(rand(dist_hard)) for i = 1:length(temps)], simulate_n, simulate_1, evaluate)

# ╔═╡ 4eb016a8-74b3-11eb-0fb3-e78e6117666b
Plots.histogram2d(unpack(traces[1])..., nbins = 100)

# ╔═╡ 9e771a08-74ac-11eb-1260-ad7e2af51b1b
@bind lb Slider(1:niters)

# ╔═╡ b8ac427c-74ac-11eb-0eca-a7234b0ab59a
@bind ub Slider(lb:niters)

# ╔═╡ 98226b20-74a8-11eb-28d4-c5d50971fcd5
mcmc_dynamics(pdfs, traces, lb:ub)

# ╔═╡ bd699f26-74ac-11eb-019e-bb6ef2c119d2


# ╔═╡ Cell order:
# ╠═9c5d8972-7485-11eb-25f7-155fbbd40d98
# ╟─128974e2-7483-11eb-03a0-15b2abc75d66
# ╠═2c24aaca-7483-11eb-05a9-6f847b7d09b7
# ╠═42bb4640-7483-11eb-0661-677c524c62b0
# ╠═eeb0be1c-7483-11eb-341f-b1996e9a53a6
# ╠═9d2f2714-749b-11eb-1403-e3a045df62ca
# ╠═ebd11c9a-7484-11eb-2941-c78e3e22d260
# ╠═0464d3ec-7489-11eb-1081-d761307263db
# ╠═94d6f4e6-74ac-11eb-0871-a31b2df5526d
# ╟─318e4a98-7483-11eb-1916-c9630ecf07e2
# ╠═27ced392-7483-11eb-3d36-7b8277daadff
# ╠═7e4e66ce-7483-11eb-238e-d15279086f3b
# ╠═9a7dc4f2-7483-11eb-36be-251be000793e
# ╠═68100d38-7483-11eb-07d5-45547ad45143
# ╠═f744509a-7483-11eb-3168-9bff07e7b245
# ╠═09fe4874-7484-11eb-28be-9f5df0586c87
# ╠═20537202-7484-11eb-1d70-a1bcbaa3c265
# ╠═3b0ac92e-7484-11eb-2e90-cf94eb2e9731
# ╠═4343d3b0-7484-11eb-388b-576f50c83335
# ╠═e84726c8-7484-11eb-1512-c5cee451507a
# ╠═f8e56030-7484-11eb-2bb6-afa2f952b085
# ╠═747691fe-7487-11eb-292e-2975ef75e7f0
# ╠═814cf4ae-7487-11eb-1b18-c11f124dd18a
# ╠═ff22c6e2-7487-11eb-3bbe-db691feb921b
# ╠═22183a3e-7487-11eb-192c-4370f0b71496
# ╠═30131820-7487-11eb-11de-9561b77139e8
# ╠═b9c69864-7487-11eb-3942-e146b6ae5ea4
# ╠═1c2dedee-7489-11eb-3a2c-519ab256505f
# ╠═b0030bf6-74a0-11eb-14c8-4f09bcb0327c
# ╠═d51078da-7488-11eb-334f-c1a0ce33384c
# ╠═ff1e6132-7488-11eb-3a82-d1e9fa247b42
# ╠═519dc07e-7489-11eb-295b-3769fa285c29
# ╠═5a8e043c-7489-11eb-23a5-9ba3521900bd
# ╠═4d3c151c-7489-11eb-2352-65f743d197d0
# ╠═dd7f08f4-748a-11eb-15ae-1f79ca5c1a0c
# ╠═92926c20-749c-11eb-37f7-e7ec05a5ee41
# ╠═98c5076a-74a1-11eb-0f34-99ffa441dee6
# ╠═d1910068-74a0-11eb-21e6-e1d2410c1646
# ╠═a2b3e42c-74a0-11eb-1678-7148d7776b6e
# ╠═cd57df24-74a2-11eb-166f-31b691e72e12
# ╠═e5df8ac4-74a2-11eb-3a36-31d7ac95fba8
# ╠═b75ae81e-74a3-11eb-2ac0-efd1a5c21f21
# ╠═e208a218-74a3-11eb-28ac-0dec5c478e15
# ╠═ee2bb440-748a-11eb-046b-e5a4741ffe99
# ╠═59576824-74b3-11eb-1a98-d773404b49e0
# ╠═b870ea20-74a4-11eb-2ab7-6972d5d2a105
# ╠═25be5166-74a8-11eb-1255-bf738e624e97
# ╠═de1d4ab8-74a7-11eb-16a1-c728c0e288b8
# ╠═745f702a-74a8-11eb-1ada-cf83599e0b17
# ╠═0603ea0c-74ad-11eb-29ef-d58f5a17aba4
# ╠═0a36105a-74ad-11eb-27c8-ed6919e3c5c8
# ╠═17ace2ae-74ad-11eb-34be-3be5f9eb6f28
# ╠═b82be6b2-74a8-11eb-1df2-9d26ac88ccbb
# ╠═4eb016a8-74b3-11eb-0fb3-e78e6117666b
# ╠═9e771a08-74ac-11eb-1260-ad7e2af51b1b
# ╠═b8ac427c-74ac-11eb-0eca-a7234b0ab59a
# ╠═98226b20-74a8-11eb-28d4-c5d50971fcd5
# ╠═bd699f26-74ac-11eb-019e-bb6ef2c119d2
