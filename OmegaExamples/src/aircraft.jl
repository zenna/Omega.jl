### A Pluto.jl notebook ###
# v0.17.5

using Markdown
using InteractiveUtils

# ╔═╡ 84739f36-65fb-4a36-a342-ae0985a759a7
begin
    import Pkg
    # activate the shared project environment|
    Pkg.activate(Base.current_project())
    using Omega, Distributions, UnicodePlots
	using Plots
	Pkg.add("FreqTables")
	using FreqTables
end

# ╔═╡ 0042d812-7771-11eb-0aff-dd1d6767a96a
md""" # Open World Model
Omega supports so-called open-world models (also called trans/variable dimensional models) which have a variable number of parameters. 

BLOG was perhaps the first probabilistic language to support open-world models.  The BLOG paper motivates them through a number of examples such as the following:

*An  unknown  number  of  aircraft  exist  in  some volume of airspace.  An aircraft’s state (position and veloc-ity) at each time step depends on its state at the previous timestep. We observe the area with radar: aircraft may appear as identical blips on a radar screen. Each blip gives the approximate position of the aircraft that generated it. However, some blips may be false detections, and some aircraft may not be detected. What aircraft exist, and what are their trajectories? Are there any aircraft that are not observed?*
"""

# ╔═╡ 05e99288-7787-11eb-2d06-f96f8b7f16e0
md"## The generative model"

# ╔═╡ 3ee1698e-9b28-4693-80ca-2ebcb51e7d7f
md"An aircraft is defined by a position and velocity"

# ╔═╡ 2d7e1730-7771-11eb-1d47-c9e05121d38b
struct Aircraft{P, V}
  position::P
  velocity::V
end

# ╔═╡ 15aeba40-7787-11eb-36de-25338cdfbca3
md"The number of aircraft is unknown, and for each aircraft the position and velocity is uncertain"

# ╔═╡ 66794654-7771-11eb-3044-ad6cf0b566f0
num_aircraft = @~ Poisson(5)

# ╔═╡ a4756686-7773-11eb-01bc-b1231fd5418a
xlb, xub, ylb, yub = 0, 1, 0, 1

# ╔═╡ aac835ae-7771-11eb-2792-838c80957a3d
function init_state(i, ω)
  x = @~ i Uniform(xlb, xub)
  y = @~ i Uniform(ylb, yub)
  vx = @~ i Normal(0, 1)
  vy = @~ i Normal(0, 1)
  Aircraft((x(ω), y(ω)), (vx(ω), vy(ω)))
end

# ╔═╡ eefa9a2c-778b-11eb-37d1-c39cc9cc53f7


# ╔═╡ 1ff3e3a2-7775-11eb-2c0c-7d255b3404ef
aircraft(ω) = manynth(init_state, num_aircraft(ω))(ω)

# ╔═╡ 2d60c906-b5cb-4e44-951c-e52f32568b73
randsample(aircraft)

# ╔═╡ af7af430-7774-11eb-3133-bfe35d03939d
state_transition(s; dt = 0.1) = 
  Aircraft(s.position .+ dt .* s.velocity, s.velocity)

# ╔═╡ 6de7d402-7774-11eb-109d-5f8fb82851c7
"simulate the aircraft for `t` timesteps from initial state `s0`"
function simulate(s, t)
  ss = [s]
  for i = 1:t - 1
	s = state_transition(s)
	push!(ss, s)
  end
  ss
end

# ╔═╡ b415b1c8-7784-11eb-1a8b-0b437ab2432d
T = 20

# ╔═╡ ebed910c-7774-11eb-3bac-f7d7b7fbc2f1
simall(ω) = simulate(aircraft(ω), T)

# ╔═╡ 0b55508a-7783-11eb-2678-5f480c20c23f
traj_sample = randsample(simall)

# ╔═╡ 684c13f0-7788-11eb-1d92-ed4736e555a7
xtraj(ta) = [t.position[1] for t in ta]

# ╔═╡ 832d5de4-7788-11eb-3833-ad03ab2f9bf9
ytraj(ta) = [t.position[2] for t in ta]

# ╔═╡ 32bfdb5e-7783-11eb-35d7-53e6e75cb44e
begin
	plt = Plots.plot(xtraj(traj_sample), ytraj(traj_sample))
	if length(traj_sample) > 1
		for i = 2:length(traj_sample)
			@show i
			Plots.plot!(plt, xtraj(traj_sample), ytraj(traj_sample))
		end
	end
	plt
end

# ╔═╡ a6b85cf0-778a-11eb-0d3b-395d8678a185
md"""### Observation Model
Every $r$ seconds we'll send out a radar pulse and sometime later (at a time dependent on the distance from the source to the airraft) we'll recieve a pulse back.  There are a few caveats:

- false positive: some other object causes a pulse
- false negatives: sometimes a radar pulse willl scattar off an aircraft
"""

# ╔═╡ cdc5380a-7789-11eb-237f-57098bc805d4
function sim_radar(a_series)
  for i = 1:length(a_series)
  end
end

# ╔═╡ ec3c6662-7786-11eb-35e3-87845ca04b0a
md"## Inference"

# ╔═╡ 5ddb4910-778b-11eb-1954-93b4bf68e7df
md"""Given a model we can do inference, sample from the posterior of any of the variables given evidence"""

# ╔═╡ bc35478c-7785-11eb-1ec9-aff81d4aa339
length(traj_sample[1])

# ╔═╡ Cell order:
# ╠═84739f36-65fb-4a36-a342-ae0985a759a7
# ╟─0042d812-7771-11eb-0aff-dd1d6767a96a
# ╟─05e99288-7787-11eb-2d06-f96f8b7f16e0
# ╟─3ee1698e-9b28-4693-80ca-2ebcb51e7d7f
# ╠═2d7e1730-7771-11eb-1d47-c9e05121d38b
# ╟─15aeba40-7787-11eb-36de-25338cdfbca3
# ╠═66794654-7771-11eb-3044-ad6cf0b566f0
# ╠═a4756686-7773-11eb-01bc-b1231fd5418a
# ╠═aac835ae-7771-11eb-2792-838c80957a3d
# ╠═eefa9a2c-778b-11eb-37d1-c39cc9cc53f7
# ╠═1ff3e3a2-7775-11eb-2c0c-7d255b3404ef
# ╠═2d60c906-b5cb-4e44-951c-e52f32568b73
# ╠═af7af430-7774-11eb-3133-bfe35d03939d
# ╠═6de7d402-7774-11eb-109d-5f8fb82851c7
# ╠═b415b1c8-7784-11eb-1a8b-0b437ab2432d
# ╠═ebed910c-7774-11eb-3bac-f7d7b7fbc2f1
# ╠═0b55508a-7783-11eb-2678-5f480c20c23f
# ╠═684c13f0-7788-11eb-1d92-ed4736e555a7
# ╠═832d5de4-7788-11eb-3833-ad03ab2f9bf9
# ╠═32bfdb5e-7783-11eb-35d7-53e6e75cb44e
# ╟─a6b85cf0-778a-11eb-0d3b-395d8678a185
# ╠═cdc5380a-7789-11eb-237f-57098bc805d4
# ╟─ec3c6662-7786-11eb-35e3-87845ca04b0a
# ╟─5ddb4910-778b-11eb-1954-93b4bf68e7df
# ╠═bc35478c-7785-11eb-1ec9-aff81d4aa339
