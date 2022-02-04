### A Pluto.jl notebook ###
# v0.17.6

using Markdown
using InteractiveUtils

# ╔═╡ e376a3a6-8105-11ec-0494-c12aa2943418
using Pkg

# ╔═╡ a02aa817-a7e4-4931-9814-86818b0ef4c2
Pkg.activate(Base.current_project())

# ╔═╡ cf4ecde4-3187-4e15-991f-6b877e82a273
using Omega

# ╔═╡ a1a65a95-ca38-411d-bbcb-c4933b83886a
using Distributions

# ╔═╡ 580dafb7-2477-40bd-94c6-13a3936481fa
using UnicodePlots

# ╔═╡ 2254169e-6c7e-4068-a7a8-8240e7922c6d
Pkg.instantiate()

# ╔═╡ d5132a1f-d43a-440d-b76b-764693a894ab
_i_ = " "

# ╔═╡ e8607b8b-44c3-4a4a-a5d4-cc54049c4624
struct Map
	name
end

# ╔═╡ 7543a48e-bdd2-470f-baeb-73aaa42d8b56
DN = Map("Donut N")

# ╔═╡ 95d9ca67-6dd0-4854-af38-b861672e348f
DS = Map("Donut S")

# ╔═╡ 6eccda57-db42-4241-9506-293fb0c0af37
V = Map("Veg")

# ╔═╡ 34db79ac-e999-4434-adea-5d45df257582
N = Map("Noodle")

# ╔═╡ 899e9468-41c4-4f31-a635-425fb9b64bcc
grid = [
	["#", "#", "#", "#",  V , "#"],
  	["#", "#", "#", _i_, _i_, _i_],
  	["#", "#", DN , _i_, "#", _i_],
  	["#", "#", "#", _i_, "#", _i_],
  	["#", "#", "#", _i_, _i_, _i_],
  	["#", "#", "#", _i_, "#",  N ],
  	[_i_, _i_, _i_, _i_, "#", "#"],
  	[DS , "#", "#", _i_, "#", "#"]
]

# ╔═╡ 40ed263a-15ac-43d8-bc78-984843bc223d


# ╔═╡ Cell order:
# ╠═e376a3a6-8105-11ec-0494-c12aa2943418
# ╠═a02aa817-a7e4-4931-9814-86818b0ef4c2
# ╠═2254169e-6c7e-4068-a7a8-8240e7922c6d
# ╠═cf4ecde4-3187-4e15-991f-6b877e82a273
# ╠═a1a65a95-ca38-411d-bbcb-c4933b83886a
# ╠═580dafb7-2477-40bd-94c6-13a3936481fa
# ╠═d5132a1f-d43a-440d-b76b-764693a894ab
# ╠═e8607b8b-44c3-4a4a-a5d4-cc54049c4624
# ╠═7543a48e-bdd2-470f-baeb-73aaa42d8b56
# ╠═95d9ca67-6dd0-4854-af38-b861672e348f
# ╠═6eccda57-db42-4241-9506-293fb0c0af37
# ╠═34db79ac-e999-4434-adea-5d45df257582
# ╠═899e9468-41c4-4f31-a635-425fb9b64bcc
# ╠═40ed263a-15ac-43d8-bc78-984843bc223d
