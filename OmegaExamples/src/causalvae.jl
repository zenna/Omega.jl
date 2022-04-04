### A Pluto.jl notebook ###
# v0.14.4

using Markdown
using InteractiveUtils

# ╔═╡ 09d8b052-ac4a-11eb-09db-b3560d91e761
using Omega

# ╔═╡ 7c492773-17bf-4dd1-9b45-2ce200441bc2
using Distributions

# ╔═╡ bdd33342-30da-4f57-ba56-ec71009ee082
md"# Causal VAE"

# ╔═╡ 300a118e-cd19-4515-a103-c9623554da8d
z = 1 ~ Normal(0, 1)

# ╔═╡ 4f788865-83dc-44fc-bd60-93e129cffd28
f(θ, z) = (-θ + z, θ + z)

# ╔═╡ 2a926551-e019-4385-b60b-55682344e11f
θs = rand(5)

# ╔═╡ 9f4f2521-03ef-4baa-8588-44555c938a6e


# ╔═╡ dbcca834-f021-4c18-beaa-f6afcd172e99
function f(ω)
	z = 1 ~ Normal(0, 1)
	μ_X, σ_X = f(θs[1], z)
	x = ~ Normal(μ_X, σ_X)
	
	# t = 0
	μ_y_0, σ_y_0 = h(θs[2], z)
	y_0 ~ normal(mu_y_0, sigma_y_0)
	
	# = 1
	μ_y_1, σ_y_1 = h(θs[3], z)
	y_1 = 3 ~ Normal(μ_y_1, σ_y_1)
	return y_1 - y_0
end

# ╔═╡ 3a4faf28-565e-41b4-b278-bbb5b32c48ad
μ_X, σ_X = f(θs[1], z)

# ╔═╡ 7b60e041-3c72-44b8-ab88-4d1af04d2a8a


# ╔═╡ Cell order:
# ╟─bdd33342-30da-4f57-ba56-ec71009ee082
# ╠═09d8b052-ac4a-11eb-09db-b3560d91e761
# ╠═7c492773-17bf-4dd1-9b45-2ce200441bc2
# ╠═300a118e-cd19-4515-a103-c9623554da8d
# ╠═4f788865-83dc-44fc-bd60-93e129cffd28
# ╠═2a926551-e019-4385-b60b-55682344e11f
# ╠═3a4faf28-565e-41b4-b278-bbb5b32c48ad
# ╠═9f4f2521-03ef-4baa-8588-44555c938a6e
# ╠═dbcca834-f021-4c18-beaa-f6afcd172e99
# ╠═7b60e041-3c72-44b8-ab88-4d1af04d2a8a
