### A Pluto.jl notebook ###
# v0.17.1

using Markdown
using InteractiveUtils

# ╔═╡ 10b12532-9e92-4eaa-a363-bad52b57e56d
begin
    import Pkg
    # activate the shared project environment
    Pkg.activate(Base.current_project())
    using Omega, Distributions, UnicodePlots
end

# ╔═╡ 91bd999c-cb92-48a0-b2ee-ec3c6408bcf1
md"# Bayesian Linear Regression"

# ╔═╡ cd99683b-f2bc-45fb-9fe3-e48a4e5e2b89
md"## Fake Data
First we'll create some fake data."

# ╔═╡ 4efa7369-1b88-4a7c-bb7a-0884fb5d9368
ndata = 20

# ╔═╡ 5a99167b-1556-4421-bc8f-5633400bd8e9
m_real = 2.5

# ╔═╡ bbb10347-38d4-460f-88ea-9f7302e58cd2
c_real = 1.7

# ╔═╡ 13c0a36a-f2e7-4de7-89ff-34d9ba3e4c06
x⃗ = rand(ndata) * 10

# ╔═╡ feff521c-04ce-4661-b6f9-c786720a72d5
y⃗ = m_real .* x⃗ .+ c_real + randn(ndata)

# ╔═╡ 26c3865c-a5d5-4c03-8ab4-375e15676605
M = @~ Normal(0.0, 2.0)

# ╔═╡ 8fa84d2c-10c6-4d11-9cf9-7fa36448715a
C = @~ Normal(0.0, 2.0)

# ╔═╡ 297d2b71-92ea-4ff0-bebc-d917ecdadab5
y(i, x, ω) = (ϵ = (@uid, i) ~ Normal(0, 0.1); M(ω) * x + C(ω))

# ╔═╡ 07769df9-223d-4de6-ad56-4398b693fcd3
randsample(ω -> y(1, 0.3, ω))

# ╔═╡ 40e81bcb-a145-4ae7-a6cc-13f85f03258e
Y⃗ = ω -> map((i, xi) -> y(i, xi, ω), 1:ndata, x⃗)

# ╔═╡ cdcece41-56cb-46d0-9f0e-a0bcda1ddf77
scatterplot(x⃗, randsample(Y⃗))

# ╔═╡ 60dad221-b909-4856-bcda-aba632a6ee42


# ╔═╡ 88a88b88-b996-496a-891a-399e56db026e
posterior = @joint(M, C) |ᶜ (Y⃗ ==ₚ y⃗)

# ╔═╡ 8e8b4718-91c5-4b30-ba02-16c861cdeb70
randsample(posterior, 1; alg = MH)

# ╔═╡ Cell order:
# ╠═91bd999c-cb92-48a0-b2ee-ec3c6408bcf1
# ╠═10b12532-9e92-4eaa-a363-bad52b57e56d
# ╠═cd99683b-f2bc-45fb-9fe3-e48a4e5e2b89
# ╠═4efa7369-1b88-4a7c-bb7a-0884fb5d9368
# ╠═5a99167b-1556-4421-bc8f-5633400bd8e9
# ╠═bbb10347-38d4-460f-88ea-9f7302e58cd2
# ╠═13c0a36a-f2e7-4de7-89ff-34d9ba3e4c06
# ╠═feff521c-04ce-4661-b6f9-c786720a72d5
# ╠═26c3865c-a5d5-4c03-8ab4-375e15676605
# ╠═8fa84d2c-10c6-4d11-9cf9-7fa36448715a
# ╠═297d2b71-92ea-4ff0-bebc-d917ecdadab5
# ╠═07769df9-223d-4de6-ad56-4398b693fcd3
# ╠═40e81bcb-a145-4ae7-a6cc-13f85f03258e
# ╠═cdcece41-56cb-46d0-9f0e-a0bcda1ddf77
# ╠═60dad221-b909-4856-bcda-aba632a6ee42
# ╠═88a88b88-b996-496a-891a-399e56db026e
# ╠═8e8b4718-91c5-4b30-ba02-16c861cdeb70
