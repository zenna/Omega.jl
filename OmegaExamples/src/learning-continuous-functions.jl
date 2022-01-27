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


# ╔═╡ Cell order:
# ╠═7c022d50-7ec4-11ec-1fde-8be8fdb0f22f
# ╟─41364972-8306-42ba-af47-b2fa0ff700d9
# ╠═0ec4fac2-b5f1-46ae-924b-61332d2f17f2
# ╠═1ee66ebe-c7f9-4719-85bf-9c1420a63c75
# ╠═8c4470f4-bda7-49cd-a123-887af6c1be53
# ╠═8379f87d-e0d6-4963-9753-ec910f06c783
# ╠═9b9c0f9f-7f0c-48c2-be27-0cb9dd5d2bef
# ╠═8f2b6e6d-d684-4b21-bc3d-d630dd93adb5
