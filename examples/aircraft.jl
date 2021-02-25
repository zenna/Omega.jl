### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ f3425176-7770-11eb-2f05-73bfcf67cc5a
using Revise

# ╔═╡ f847f340-7770-11eb-3231-d10bb101f2a2
using Omega

# ╔═╡ 72b4e374-7771-11eb-3a0a-3dc3066ee8be
using Distributions

# ╔═╡ f4126600-7771-11eb-357d-19b214eba52a
using UnicodePlots

# ╔═╡ 0042d812-7771-11eb-0aff-dd1d6767a96a
md""" # Open World Model
Omega supports so-called open-world models (also called trans/variable dimensional models) which have a variable number of parameters. 

BLOG was perhaps the first probabilistic language to support open-world models.  The BLOG paper motivates them through a number of examples such as the following:

*An  unknown  number  of  aircraft  exist  in  some volume of airspace.  An aircraft’s state (position and veloc-ity) at each time step depends on its state at the previous timestep. We observe the area with radar: aircraft may appear as identical blips on a radar screen. Each blip gives the approximate position of the aircraft that generated it. However, some blips may be false detections, and some aircraft may not be detected. What aircraft exist, and what are their trajectories? Are there any aircraft that are not observed?*
"""

# ╔═╡ 2d7e1730-7771-11eb-1d47-c9e05121d38b
struct Aircraft{P, V}
  position::P
  velocity::V
end

# ╔═╡ 66794654-7771-11eb-3044-ad6cf0b566f0
num_aircraft_distrib = Poisson(5)

# ╔═╡ 4effc1c4-7771-11eb-19d8-77ab994d8b09
aircrafts = 1 ~ num_aircraft_distrib

# ╔═╡ a4756686-7773-11eb-01bc-b1231fd5418a
xlb, xub, ylb, yub = 0, 1, 0, 1

# ╔═╡ aac835ae-7771-11eb-2792-838c80957a3d
function init_state(ω)
  x = 1 ~ Uniform(xlb, xub)
  y = 2 ~ Uniform(ylb, yub)
  vx = 3 ~ Normal(0, 1)
  vy = 4 ~ Normal(0, 1)
  Aircraft((x(ω), y(ω)), (vx(ω), vy(ω)))
end

# ╔═╡ 1ff3e3a2-7775-11eb-2c0c-7d255b3404ef
aircraft(ω) = 1:num_aircraft(ω) <| init_state

# ╔═╡ af7af430-7774-11eb-3133-bfe35d03939d
state_transition(s) = s + 3

# ╔═╡ 6de7d402-7774-11eb-109d-5f8fb82851c7
"simulate the aircraft for `t` timesteps from initial state `s0`"
function simulate(s0, t)
  ss = [s0]
  for i = 1:t
	s = state_transition(t)
	push!(ss, s)
  end
  ss
end

# ╔═╡ ebed910c-7774-11eb-3bac-f7d7b7fbc2f1


# ╔═╡ Cell order:
# ╟─0042d812-7771-11eb-0aff-dd1d6767a96a
# ╠═f3425176-7770-11eb-2f05-73bfcf67cc5a
# ╠═f847f340-7770-11eb-3231-d10bb101f2a2
# ╠═72b4e374-7771-11eb-3a0a-3dc3066ee8be
# ╠═f4126600-7771-11eb-357d-19b214eba52a
# ╠═2d7e1730-7771-11eb-1d47-c9e05121d38b
# ╠═66794654-7771-11eb-3044-ad6cf0b566f0
# ╠═4effc1c4-7771-11eb-19d8-77ab994d8b09
# ╠═a4756686-7773-11eb-01bc-b1231fd5418a
# ╠═aac835ae-7771-11eb-2792-838c80957a3d
# ╠═1ff3e3a2-7775-11eb-2c0c-7d255b3404ef
# ╠═af7af430-7774-11eb-3133-bfe35d03939d
# ╠═6de7d402-7774-11eb-109d-5f8fb82851c7
# ╠═ebed910c-7774-11eb-3bac-f7d7b7fbc2f1
