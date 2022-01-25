### A Pluto.jl notebook ###
# v0.17.5

using Markdown
using InteractiveUtils

# ╔═╡ 41441e1e-7abc-11ec-16a6-b57bfbb0ac7a
import Pkg

# ╔═╡ 4470d3fb-9dc5-4f49-95b6-f8296a538f0c
Pkg.activate("~/CausalRL_Proj/Omega.jl/Project.toml")

# ╔═╡ 10af03b3-a26b-449d-92ee-6ad9c953a8b9
Pkg.add("Distributions")

# ╔═╡ e6c6e201-cd4f-441b-8d6d-1e69a32e3883
using Omega, Distributions

# ╔═╡ ef848a04-a998-4c13-a607-75c6232cf19b
 @~Poisson(5)

# ╔═╡ Cell order:
# ╠═41441e1e-7abc-11ec-16a6-b57bfbb0ac7a
# ╠═4470d3fb-9dc5-4f49-95b6-f8296a538f0c
# ╠═10af03b3-a26b-449d-92ee-6ad9c953a8b9
# ╠═e6c6e201-cd4f-441b-8d6d-1e69a32e3883
# ╠═ef848a04-a998-4c13-a607-75c6232cf19b
