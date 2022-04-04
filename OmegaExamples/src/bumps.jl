### A Pluto.jl notebook ###
# v0.17.1

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ dc0623d0-3438-4bf3-9bd0-ea2b35589b7e
begin
    import Pkg
    # activate the shared project environment
    Pkg.activate(Base.current_project())
	#Pkg.add("Plots")
    using Omega, RCall, Plots, Distributions
end

# ╔═╡ d5bac81e-e0e1-40f0-b889-529f8ed7719c
using PlutoUI

# ╔═╡ 01271358-45ae-11ec-30f1-8521b73aa741
md"# Constrained Flows

Deep neural networks can be used to cosntruct very flexible families of probability distributions.  However, these families might be __too__ flexible in the sense that they contain distributions which are inconsistent with facts that we know.

We can use the distributional inference features of Omega to incorporate certain kinds of domain knowledge into these families.  For example, we might know that the distribution has exactly two modes."

# ╔═╡ 6353b3f7-e6e5-46e4-80e1-272d8b9286bd
md"First let's setup a Bayesian normalizing flow from.  A normalizing flow is a real values probability distribution, which among other things, allows us to easily compute the pdf of any value"

# ╔═╡ 836d9f48-5f7a-4963-955d-9f4e4a7c8833
function g(k, y)
	if k == 1
		1
	elseif k == 2
		log(y/(1-y))
	elseif iseven(k)
		(y - 0.5)
	else
		(y - 0.5) * log(y/(1-y))
	end
end

# ╔═╡ e7b83751-0720-4cda-8efa-3f14ee0c98e3
@bind x1 Slider(-10:0.1:10)

# ╔═╡ b565412f-3e41-44f3-879e-fd7aace7a1b6
@bind x2 Slider(-10:0.1:10)

# ╔═╡ 2a0e9e4f-cdf7-4ac7-9dae-9a3249c61dd7
@bind x3 Slider(-10:0.1:10)

# ╔═╡ af3ebb43-a593-4a07-8b63-869c139f6f05
@bind x4 Slider(-10:0.1:10)

# ╔═╡ f21c55ce-4539-437a-a667-2f489134a4f9
@bind x5 Slider(-10:0.1:10)

# ╔═╡ a1f683a2-f9d3-4829-abb0-6fe6b831b1e8
@bind x6 Slider(-10:0.1:10)

# ╔═╡ 97b74c99-d460-485a-a297-85735d4cb68a
@bind x7 Slider(-10:0.1:10)

# ╔═╡ 4ba5a65b-c239-4c57-80df-305148c3d832
@bind x8 Slider(-10:0.1:10)

# ╔═╡ 7d78fea3-e4d9-4948-9fa0-7e2a156bc2ec
@bind x9 Slider(-10:0.1:10)

# ╔═╡ 75bdc477-2d3b-43a2-bfb7-899b51aa6d25
@bind x10 Slider(-10:0.1:10)

# ╔═╡ 817599f0-d59f-40e4-8509-b21abcaf9d02


# ╔═╡ 93adbc21-47c7-4050-bf74-b9d782b42930
PlutoUI.RangeSlider

# ╔═╡ d2efde36-bfe2-49e6-9fde-cdd4651c1c34
#m = Metalog([x1, x2, x3, x4, x5, x6, x7, x8, x9, x10])

# ╔═╡ 3e674ded-4ec1-4019-a678-1ecafaa75330
md"Now let's use the random conditional distribution"

# ╔═╡ 1c7e60a0-eba8-40a6-a1ca-5f85025ec451
function nmodes(xs::Vector{Float64})
	@show rcopy(R"multimode::nmodes($xs, 3.0)")
end

# ╔═╡ 19729f65-9185-407e-ae33-f5678cc3157e
nmodes_dist(ml; nsamples = 10000) = nmodes(randsample(ml, nsamples))

# ╔═╡ 4869a4b0-c5a1-453d-8697-b5fb3a394a60
α = manynth(Normal(0, 3), 1:10)

# ╔═╡ ad4473fd-9ddc-49b9-bfc9-79139fe825de
function quantile(m::Metalog, y)
	ncoeff = length(m.α)

	sum(αi * g(i, y) for (i, αi) in enumerate(m.α))		
end

# ╔═╡ 8ca63ca5-9bb3-4dd0-a44c-a468fd922837
m = Metalog(rand(3))

# ╔═╡ 0bb1ac69-53a2-4bc4-86a1-fbe04c61bf00
sample() = quantile(m, rand())

# ╔═╡ d2c3ed3e-c337-43fb-9645-ffd605116317
data = [sample() for i = 1:10000]

# ╔═╡ e80fd58a-e123-4303-af20-68d1582d102b
histogram(data)

# ╔═╡ 29c67690-ae3f-42d8-8e97-9ddd9de1474c
nmodes(data)

# ╔═╡ 6ffb21fa-0c48-4ade-a56f-331acca729f2
M = pw(Metalog, α)

# ╔═╡ 8e2da9d5-3e9b-4efc-a190-698235e87ef5


# ╔═╡ 9424a06b-fd04-40e2-a6a2-cbfb6f665e4c
X(ω) = quantile(M(ω), (@~ StdUniform{Float64}())(ω))

# ╔═╡ 64de684f-e38e-48e3-9eb3-88cc2f67b39e
x⃗_α = rid(X, α)

# ╔═╡ 2f9c9660-cbb8-4bf4-8cc0-08a18cfced9e
randsample(x⃗_α)

# ╔═╡ 9ebfa368-5053-49a3-a5cf-f3a3e55c96ab
x⃗_α_nmodes = pw(nmodes_dist, x⃗_α)

# ╔═╡ 583b1289-4a88-4885-b6ab-3aa325369dda
ω = defω()

# ╔═╡ a35a3b27-7203-4b2d-9076-2e777283034d
x⃗_α_nmodes(ω)

# ╔═╡ 954f6d88-c734-4038-86b5-923cddd3b798
datadata = randsample(x⃗_α(ω), 10000)

# ╔═╡ c069e0eb-e8c5-47e1-a362-d7a8764fde41
histogram(datadata)

# ╔═╡ bcc32ecd-7479-4be3-8e3c-a7a913a5cbfb
nmodes(datadata)

# ╔═╡ 3226c9ad-9959-4ede-97ed-924d506fa2e5
nmodes([X(ω) for i = 1:10000])

# ╔═╡ a711f8d2-b87b-47ca-991a-7af29980c14e
M_ = randsample(cnd(M, x⃗_α_nmodes ==ₚ 3), 1; alg = RejectionSample)

# ╔═╡ 3cf857e8-fd28-482a-a664-17a16c5fc958
sim(m::Metalog; nsamples = 10000) = [quantile(m, rand()) for i = 1:nsamples]

# ╔═╡ cd8c89b2-0ad4-474b-9fc8-9b33aae02704
dx = sim(M_[1])

# ╔═╡ 7c321d1f-61c9-4d5c-bca7-4887a96742e7
nmodes(dx)

# ╔═╡ 1c391c6e-9519-4e01-bb73-7e57e8ceb7ea


# ╔═╡ c79791f2-ce51-4308-98b6-58f3b08ae6f9
struct Metalog{A}
	α::A  # Coefficients
end

# ╔═╡ 28fe7962-d5b2-4ec9-a08e-a2d32a7d789c
(m::Metalog)(ω) = quantile(m(ω), (@~ StdUniform{Float64}())(ω))

# ╔═╡ Cell order:
# ╠═01271358-45ae-11ec-30f1-8521b73aa741
# ╠═dc0623d0-3438-4bf3-9bd0-ea2b35589b7e
# ╠═6353b3f7-e6e5-46e4-80e1-272d8b9286bd
# ╠═c79791f2-ce51-4308-98b6-58f3b08ae6f9
# ╠═836d9f48-5f7a-4963-955d-9f4e4a7c8833
# ╠═ad4473fd-9ddc-49b9-bfc9-79139fe825de
# ╠═d5bac81e-e0e1-40f0-b889-529f8ed7719c
# ╠═e7b83751-0720-4cda-8efa-3f14ee0c98e3
# ╠═b565412f-3e41-44f3-879e-fd7aace7a1b6
# ╠═2a0e9e4f-cdf7-4ac7-9dae-9a3249c61dd7
# ╠═af3ebb43-a593-4a07-8b63-869c139f6f05
# ╠═f21c55ce-4539-437a-a667-2f489134a4f9
# ╠═a1f683a2-f9d3-4829-abb0-6fe6b831b1e8
# ╠═97b74c99-d460-485a-a297-85735d4cb68a
# ╠═4ba5a65b-c239-4c57-80df-305148c3d832
# ╠═7d78fea3-e4d9-4948-9fa0-7e2a156bc2ec
# ╠═75bdc477-2d3b-43a2-bfb7-899b51aa6d25
# ╠═817599f0-d59f-40e4-8509-b21abcaf9d02
# ╠═93adbc21-47c7-4050-bf74-b9d782b42930
# ╠═d2efde36-bfe2-49e6-9fde-cdd4651c1c34
# ╠═8ca63ca5-9bb3-4dd0-a44c-a468fd922837
# ╠═0bb1ac69-53a2-4bc4-86a1-fbe04c61bf00
# ╠═d2c3ed3e-c337-43fb-9645-ffd605116317
# ╠═e80fd58a-e123-4303-af20-68d1582d102b
# ╠═29c67690-ae3f-42d8-8e97-9ddd9de1474c
# ╠═3e674ded-4ec1-4019-a678-1ecafaa75330
# ╠═1c7e60a0-eba8-40a6-a1ca-5f85025ec451
# ╠═19729f65-9185-407e-ae33-f5678cc3157e
# ╠═4869a4b0-c5a1-453d-8697-b5fb3a394a60
# ╠═6ffb21fa-0c48-4ade-a56f-331acca729f2
# ╠═28fe7962-d5b2-4ec9-a08e-a2d32a7d789c
# ╠═8e2da9d5-3e9b-4efc-a190-698235e87ef5
# ╠═9424a06b-fd04-40e2-a6a2-cbfb6f665e4c
# ╠═64de684f-e38e-48e3-9eb3-88cc2f67b39e
# ╠═2f9c9660-cbb8-4bf4-8cc0-08a18cfced9e
# ╠═9ebfa368-5053-49a3-a5cf-f3a3e55c96ab
# ╠═583b1289-4a88-4885-b6ab-3aa325369dda
# ╠═a35a3b27-7203-4b2d-9076-2e777283034d
# ╠═954f6d88-c734-4038-86b5-923cddd3b798
# ╠═c069e0eb-e8c5-47e1-a362-d7a8764fde41
# ╠═bcc32ecd-7479-4be3-8e3c-a7a913a5cbfb
# ╠═3226c9ad-9959-4ede-97ed-924d506fa2e5
# ╠═a711f8d2-b87b-47ca-991a-7af29980c14e
# ╠═3cf857e8-fd28-482a-a664-17a16c5fc958
# ╠═cd8c89b2-0ad4-474b-9fc8-9b33aae02704
# ╠═7c321d1f-61c9-4d5c-bca7-4887a96742e7
# ╠═1c391c6e-9519-4e01-bb73-7e57e8ceb7ea
