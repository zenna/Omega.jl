### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ 6ffee000-72d8-11eb-33dc-5dd82601e86c
using Plots

# ╔═╡ 853ee816-72d8-11eb-34ce-9185505f361f
using Distributions

# ╔═╡ 7f578136-72da-11eb-1b9c-8d675524f499
plotly()

# ╔═╡ 7cd2b2ca-72d8-11eb-1aae-eb998368d717
md"Let's create a bivariate mixture distribution"

# ╔═╡ 5ba4fcd2-72da-11eb-1558-310e094e6759
m2 = MixtureModel(
	  [MvNormal([0.9, 0.0], [0.3, 0.2]),
	   MvNormal([2.0, 3.0], [0.3, 0.4]),
	   MvNormal([-2.0, -1.0], [0.25, 0.33])],
	  [0.5, 0.3, 0.2]);

# ╔═╡ 9d8de854-72d8-11eb-2efb-3f9ceda31abc
mpdf(x, y) = pdf(m2, [x, y])

# ╔═╡ aaef092e-72d8-11eb-1e69-514aeef1bea1
mpdf(0.2, 0.1)

# ╔═╡ 97343378-72d8-11eb-32ac-b5d1ea1b982b
plt1 = Plots.surface(-5:0.1:5, -5:0.1:5, mpdf, c = :blues, alpha = 0.5)

# ╔═╡ 49f87422-72db-11eb-2248-4d52e0cfa0b2
md"Let's vary the temperature"

# ╔═╡ 5e6e59c4-72db-11eb-2ee1-b3a42f114dd5
"pdf of mv at temperature `temp`"
mpdf_temp(x, y, temp) = (1 - exp(- mpdf(x, y) / temp)) / 10

# ╔═╡ a6546590-72dc-11eb-07d4-076e44176ffc
plt2 = Plots.surface!(plt1, -5:0.1:5, -5:0.1:5, (x,y) -> mpdf_temp(x, y, 0.0000001), c = :heat, alpha = 0.8, wireframe = true)

# ╔═╡ Cell order:
# ╠═6ffee000-72d8-11eb-33dc-5dd82601e86c
# ╠═7f578136-72da-11eb-1b9c-8d675524f499
# ╠═853ee816-72d8-11eb-34ce-9185505f361f
# ╠═7cd2b2ca-72d8-11eb-1aae-eb998368d717
# ╠═5ba4fcd2-72da-11eb-1558-310e094e6759
# ╠═9d8de854-72d8-11eb-2efb-3f9ceda31abc
# ╠═aaef092e-72d8-11eb-1e69-514aeef1bea1
# ╠═97343378-72d8-11eb-32ac-b5d1ea1b982b
# ╟─49f87422-72db-11eb-2248-4d52e0cfa0b2
# ╠═5e6e59c4-72db-11eb-2ee1-b3a42f114dd5
# ╠═a6546590-72dc-11eb-07d4-076e44176ffc
