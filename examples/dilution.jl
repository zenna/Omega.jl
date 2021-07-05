### A Pluto.jl notebook ###
# v0.14.8

using Markdown
using InteractiveUtils

# ╔═╡ f0f80b1a-d090-11eb-2b0d-d11fd8196311
using Omega, Distributions

# ╔═╡ daa9fd86-5a36-4aa2-842e-477cdb19b8d5
md"# Probability Dilution
Probability dilution is refers to scenarios where one can increase one's confidence by increasing the noisyness of one's measurement device.

Here we'll use an example on microcrip certification to demonstrate."

# ╔═╡ 62257a75-2949-4afc-8543-fe3fa4073be5
md"## Example: Chip certification

Imagine you're a microchip certification engineer.  You probe microchips coming off the supply line to see if they are good or bad.  A microchip is bad if its power pin (which is the first pin) has a zero voltage.  If any of the other pins have zero voltage it's salvageable, and we'll say it's a good pin.  For simplicitly, we assume that only one pin can have a zero voltage."

# ╔═╡ 53572568-9d02-465a-baba-1c624d79d4b5
md"We'll express our prior belief over which pin is faulty using a discrete uniform distribution over the 10 pins:"

# ╔═╡ 4936c45a-a5bf-49cb-bfdc-c05883d5982b
faulty_pin = 1 ~ DiscreteUniform(1, 10)

# ╔═╡ 57c308fa-a2e7-49fb-b52d-41346ee7ea0d
md"The probe tells us which pin is faulty.  Unfortunately, the probe is a little error probe.  Under normal operation it gives back the true answer, but with some probability it just gives back a random answer between 1 and 10"

# ╔═╡ d3af8df6-5375-4a52-9432-41ef6227af0c
error_prob_rv(id, ω) = 0.01 # We're making this a random variable to be able to intervene it later

# ╔═╡ aa5ea98f-5db3-4de5-89e4-fe1ca27c0157
error_prob = 2 ~ error_prob_rv

# ╔═╡ ad3ec928-dc20-4987-aaed-78e8c4141d3e
function measure(ω)
	error_prob_ = error_prob(ω)
	error = ω |> (3 ~ Bernoulli(error_prob_))
	if error
		ω |> (4 ~ DiscreteUniform(1, 10))
	else
		faulty_pin(ω)
	end
end
		

# ╔═╡ 87199546-b427-4908-9531-28d40995efa8
md"As described above, a chip is bad if the faulty_pin is pin 1"

# ╔═╡ 4b8285ca-0fa8-4c38-a2a9-870169a2c1d7
bad_chip = faulty_pin ==ₚ 1

# ╔═╡ 0ed2799b-0e1b-434a-85be-99a3869a89c7
prob(x; n = 1000) = mean(randsample(x, n))

# ╔═╡ 505f497c-2852-44f2-bf17-8bfb12886554
md"The probability that it's a bad chip is:"

# ╔═╡ fc03484c-206d-4c3d-90f9-773e3b9b0a90
prob(bad_chip)

# ╔═╡ 413d05ce-ed65-406e-be97-32a2bad22d92
md"Now suppose we use our probe and observe a measurement of 1"

# ╔═╡ ff0aced3-466f-44e8-8d84-9521fca7c7c4
evidence = measure ==ₚ 1;

# ╔═╡ 32b3da83-0fb4-4a99-9742-46f9ad13eb8b
conditional_bad_chip = cnd(bad_chip, evidence);

# ╔═╡ 5ddfb321-d696-4853-bb9a-f3b8593f074d
md"Given the evidence, the conditional probability the chip is bad is high, at:"

# ╔═╡ ff904fa3-898b-4c35-a1c4-8a08ca5f82df
prob_bad = prob(conditional_bad_chip)

# ╔═╡ ae28acc2-fb0f-4189-bdaa-574a3e090f75
md"The certification handbook says a chip can be ceritifed if there's less than a 20% chance that it is faulty"

# ╔═╡ dbe58fac-bc39-4ee1-8930-6bb4e8453317
can_certify(p) = p < 0.2

# ╔═╡ 03ac41b7-10fd-4466-976d-f2815fe655a2
md"Clearly, we cannot certify this chip:"

# ╔═╡ 6b9ac9fa-56c3-453f-aba7-69cd193d91c3
can_certify(prob_bad)

# ╔═╡ 9ef8cafd-49e5-439a-9723-479babd7e6d7
md" \"Not to worry!\" your colleague.  Sneaky Simon says.  \"Just use the bad probe.\""

# ╔═╡ 8c128635-e46d-418e-8c51-d74fc55973e4
md"We'll use `intervene` in Omega to construct a different model where the error rate is different"

# ╔═╡ aa15703f-6137-4d67-bb25-bec070d3d193
error_prob_bad(ω) = 0.9# We're making this a random variable to be able to intervene it later

# ╔═╡ da0608ac-94bd-4ba1-81be-1cde40bd4cae
conditional_bad_chip_bad_probe = intervene(conditional_bad_chip, error_prob => error_prob_bad);

# ╔═╡ 828161b0-c32e-4ae8-9206-1f7ce95dfda4
prob_bad_bad = prob(conditional_bad_chip_bad_probe)

# ╔═╡ 1e1a3659-0a82-46c1-9b6e-0f8de142f9be
md"Job done?"

# ╔═╡ b6470b88-3ac0-4ccf-81df-c6f80e409a64
can_certify(prob_bad_bad)

# ╔═╡ a3ae5d57-8e08-4ddc-b864-29bc3d01f785


# ╔═╡ Cell order:
# ╟─daa9fd86-5a36-4aa2-842e-477cdb19b8d5
# ╟─62257a75-2949-4afc-8543-fe3fa4073be5
# ╟─53572568-9d02-465a-baba-1c624d79d4b5
# ╠═f0f80b1a-d090-11eb-2b0d-d11fd8196311
# ╠═4936c45a-a5bf-49cb-bfdc-c05883d5982b
# ╟─57c308fa-a2e7-49fb-b52d-41346ee7ea0d
# ╠═d3af8df6-5375-4a52-9432-41ef6227af0c
# ╠═aa5ea98f-5db3-4de5-89e4-fe1ca27c0157
# ╠═ad3ec928-dc20-4987-aaed-78e8c4141d3e
# ╟─87199546-b427-4908-9531-28d40995efa8
# ╠═4b8285ca-0fa8-4c38-a2a9-870169a2c1d7
# ╠═0ed2799b-0e1b-434a-85be-99a3869a89c7
# ╟─505f497c-2852-44f2-bf17-8bfb12886554
# ╠═fc03484c-206d-4c3d-90f9-773e3b9b0a90
# ╟─413d05ce-ed65-406e-be97-32a2bad22d92
# ╠═ff0aced3-466f-44e8-8d84-9521fca7c7c4
# ╠═32b3da83-0fb4-4a99-9742-46f9ad13eb8b
# ╟─5ddfb321-d696-4853-bb9a-f3b8593f074d
# ╠═ff904fa3-898b-4c35-a1c4-8a08ca5f82df
# ╟─ae28acc2-fb0f-4189-bdaa-574a3e090f75
# ╠═dbe58fac-bc39-4ee1-8930-6bb4e8453317
# ╟─03ac41b7-10fd-4466-976d-f2815fe655a2
# ╠═6b9ac9fa-56c3-453f-aba7-69cd193d91c3
# ╟─9ef8cafd-49e5-439a-9723-479babd7e6d7
# ╟─8c128635-e46d-418e-8c51-d74fc55973e4
# ╠═aa15703f-6137-4d67-bb25-bec070d3d193
# ╠═da0608ac-94bd-4ba1-81be-1cde40bd4cae
# ╠═828161b0-c32e-4ae8-9206-1f7ce95dfda4
# ╟─1e1a3659-0a82-46c1-9b6e-0f8de142f9be
# ╠═b6470b88-3ac0-4ccf-81df-c6f80e409a64
# ╠═a3ae5d57-8e08-4ddc-b864-29bc3d01f785
