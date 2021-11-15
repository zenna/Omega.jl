### A Pluto.jl notebook ###
# v0.17.0

using Markdown
using InteractiveUtils

# ╔═╡ f0f80b1a-d090-11eb-2b0d-d11fd8196311
using Omega, Distributions, UnicodePlots

# ╔═╡ daa9fd86-5a36-4aa2-842e-477cdb19b8d5
md"# Probability Dilution
Probability dilution is refers to scenarios where one can increase one's confidence by increasing the noisyness of one's measurement device.

Here we'll use an example on microcrip certification to demonstrate."

# ╔═╡ 62257a75-2949-4afc-8543-fe3fa4073be5
md"## Example: Chip certification

Imagine you're a microchip certification engineer.  You probe microchips coming off the supply line to see if they are good or bad.  A microchip is bad if its power pin (which is the first pin) has a zero voltage.  If any of the other pins have zero voltage it's salvageable, and we'll say it's a good pin.  For simplicitly, we assume that only one (and exactly one) pin is faulty."

# ╔═╡ 53572568-9d02-465a-baba-1c624d79d4b5
md"We'll express our prior belief over which pin is faulty using a discrete uniform distribution over the 10 pins:"

# ╔═╡ 49b116d3-dc2f-4e1d-9bff-41131e8148c2
Normal

# ╔═╡ 4936c45a-a5bf-49cb-bfdc-c05883d5982b
faulty_pin = 1 ~ DiscreteUniform(1, 10)

# ╔═╡ 57c308fa-a2e7-49fb-b52d-41346ee7ea0d
md"The probe tells us which pin is faulty.  Unfortunately, the probe is a little error prone.  Under normal operation it gives back the true answer, but with some probability it just gives back a random answer between 1 and 10"

# ╔═╡ d3af8df6-5375-4a52-9432-41ef6227af0c
error_prob_rv(id, ω) = 0.01 # We're making this a random variable to be able to intervene it later

# ╔═╡ aa5ea98f-5db3-4de5-89e4-fe1ca27c0157
error_prob = 2 ~ error_prob_rv

# ╔═╡ b0769639-7b6a-4d95-bc8d-bdedd5d27c4f
error_occurred(ω) = (3 ~ Bernoulli(error_prob(ω)))(ω)

# ╔═╡ 8e2fb0c5-ca50-4bcb-85bf-d78c06ea5653
alternative_pin = 4 ~ DiscreteUniform(1, 10)

# ╔═╡ ad3ec928-dc20-4987-aaed-78e8c4141d3e
function measure(ω)
	if error_occurred(ω)
		alternative_pin(ω)
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

# ╔═╡ 233e3ee2-e56c-4c4d-a53d-83c144c303d0
md"Given the evidence, we can look at our conditional belief over which pin is faulty:"

# ╔═╡ 5774b63a-d492-490e-862a-0c3645722885
histogram(randsample(cnd(faulty_pin, evidence), 1000))

# ╔═╡ c6d93cdd-a2bd-4e5b-b835-1509cc582978
md"And compute the conditional probability that it is indeed a bad chip (faulty pin == 1)"

# ╔═╡ 32b3da83-0fb4-4a99-9742-46f9ad13eb8b
conditional_bad_chip = cnd(bad_chip, evidence);

# ╔═╡ 5ddfb321-d696-4853-bb9a-f3b8593f074d
md"Given the evidence, the conditional probability the chip is bad is high, at:"

# ╔═╡ ff904fa3-898b-4c35-a1c4-8a08ca5f82df
prob_bad = prob(conditional_bad_chip)

# ╔═╡ ae28acc2-fb0f-4189-bdaa-574a3e090f75
md"The certification handbook says a chip can be ceritifed if there's less than a 20% chance that it is faulty"

# ╔═╡ dbe58fac-bc39-4ee1-8930-6bb4e8453317
can_certify(p) = p < 0.3

# ╔═╡ 03ac41b7-10fd-4466-976d-f2815fe655a2
md"Clearly, we cannot certify this chip:"

# ╔═╡ 6b9ac9fa-56c3-453f-aba7-69cd193d91c3
can_certify(prob_bad)

# ╔═╡ 9ef8cafd-49e5-439a-9723-479babd7e6d7
md" \"Not to worry!\" your colleague.  Sneaky Simon says.  \"Just use the bad probe.\""

# ╔═╡ 8c128635-e46d-418e-8c51-d74fc55973e4
md"We'll use `intervene` in Omega to construct a different model where the error rate is different"

# ╔═╡ aa15703f-6137-4d67-bb25-bec070d3d193
error_prob_noisy = 0.9

# ╔═╡ da0608ac-94bd-4ba1-81be-1cde40bd4cae
conditional_bad_chip_noisy_probe = intervene(conditional_bad_chip, error_prob => error_prob_noisy);

# ╔═╡ 828161b0-c32e-4ae8-9206-1f7ce95dfda4
prob_bad_noisy = prob(conditional_bad_chip_noisy_probe)

# ╔═╡ 1e1a3659-0a82-46c1-9b6e-0f8de142f9be
md"Job done?"

# ╔═╡ b6470b88-3ac0-4ccf-81df-c6f80e409a64
can_certify(prob_bad_noisy)

# ╔═╡ abe64bc4-cdef-4cb5-80cc-2e99e792ecab
md"Apparently, Sneaky Simon was right.  Using the bad probe has allowed us to certify the chip.  Is this right?  If not, what has gone wrong?"

# ╔═╡ 672b6bfa-54ce-4b12-80f0-ee930a777cbc
probwow = pw(prob, rid(conditional_bad_chip_noisy_probe, (faulty_pin, alternative_pin)))

# ╔═╡ 36a6cb8a-f81e-4e05-9dd0-a475e88ab62c
histogram(randsample(probwow, 100))

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f"
Omega = "1af16e33-887a-59b3-8344-18f1671b3ade"
UnicodePlots = "b8865327-cd53-5732-bb35-84acbb429228"

[compat]
Distributions = "~0.23.12"
UnicodePlots = "~2.4.6"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[Cassette]]
git-tree-sha1 = "6ce3cd755d4130d43bab24ea5181e77b89b51839"
uuid = "7057c7e9-c182-5462-911a-8362d720325c"
version = "0.3.9"

[[ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "f885e7e7c124f8c92650d61b9477b9ac2ee607dd"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.11.1"

[[ChangesOfVariables]]
deps = ["LinearAlgebra", "Test"]
git-tree-sha1 = "9a1d594397670492219635b35a3d830b04730d62"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.1"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "dce3e3fea680869eaa0b774b2e8343e9ff442313"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.40.0"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[Crayons]]
git-tree-sha1 = "3f71217b538d7aaee0b69ab47d9b7724ca8afa0d"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.0.4"

[[DataAPI]]
git-tree-sha1 = "cc70b17275652eb47bc9e5f81635981f13cea5c8"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.9.0"

[[DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "7d9d316f04214f7efdbb6398d545446e246eff02"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.10"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[Distributions]]
deps = ["FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "StaticArrays", "Statistics", "StatsBase", "StatsFuns"]
git-tree-sha1 = "501c11d708917ca09ce357bed163dbaf0f30229f"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.23.12"

[[DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "b19534d1895d702889b219c382a6e18010797f0b"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.6"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays"]
git-tree-sha1 = "502b3de6039d5b78c76118423858d981349f3823"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.9.7"

[[Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[InferenceBase]]
deps = ["OmegaCore"]
path = "../../../home/zenna/repos/Omega.jl/InferenceBase"
uuid = "5213bc24-6d0f-4e1b-8b55-aef4cfc4ccc3"
version = "0.1.0"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "a7254c0acd8e62f1ac75ad24d5db43f5f19f3c65"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.2"

[[IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "642a199af8b68253517b80bd3bfd17eb4e84df6e"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.3.0"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "be9eef9f9d78cecb6f262f3c10da151a6c5ab827"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.5"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[Omega]]
deps = ["Distributions", "InferenceBase", "OmegaCore", "OmegaDistributions", "OmegaMH", "OmegaSoftPredicates", "Reexport", "ReplicaExchange", "SoftPredicates"]
path = "../../../home/zenna/repos/Omega.jl"
uuid = "1af16e33-887a-59b3-8344-18f1671b3ade"
version = "0.2.0"

[[OmegaCore]]
deps = ["Future", "Random", "Reexport", "Spec"]
path = "../../../home/zenna/repos/Omega.jl/OmegaCore"
uuid = "84d23798-d00f-4e9b-a82e-be69778c030a"
version = "0.1.0"

[[OmegaDistributions]]
deps = ["Distributions", "OmegaCore"]
path = "../../../home/zenna/repos/Omega.jl/connectors/OmegaDistributions"
uuid = "4ee16af8-c862-4b7a-9514-3b66b113c005"
version = "0.1.0"

[[OmegaMH]]
deps = ["InferenceBase", "OmegaCore", "SoftPredicates"]
path = "../../../home/zenna/repos/Omega.jl/OmegaMH"
uuid = "89eb2d39-e1f3-436d-870a-9a4679d6d79e"
version = "0.1.0"

[[OmegaSoftPredicates]]
deps = ["InferenceBase", "OmegaCore", "SoftPredicates"]
path = "../../../home/zenna/repos/Omega.jl/connectors/OmegaSoftPredicates"
uuid = "ffc32627-273f-428b-9998-33a39d288549"
version = "0.1.0"

[[OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse", "Test"]
git-tree-sha1 = "95a4038d1011dfdbde7cecd2ad0ac411e53ab1bc"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.10.1"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00cfd92944ca9c760982747e9a1d0d5d86ab1e5a"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.2"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "78aadffb3efd2155af139781b8a8df1ef279ea39"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.4.2"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[ReplicaExchange]]
deps = ["InferenceBase", "OmegaCore", "Spec"]
path = "../../../home/zenna/repos/Omega.jl/ReplicaExchange"
uuid = "5ad4e244-73e6-47c5-b007-45e12ac3dae1"
version = "0.1.0"

[[Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "bf3188feca147ce108c76ad82c2792c57abe7b1f"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.0"

[[Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "68db32dff12bb6127bac73c209881191bf0efbb7"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.3.0+0"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SoftPredicates]]
deps = ["Cassette", "DocStringExtensions", "InferenceBase", "LinearAlgebra", "Spec"]
path = "../../../home/zenna/repos/Omega.jl/SoftPredicates"
uuid = "5345b20a-9614-40c4-b281-8f4998fc0f3b"
version = "0.1.0"

[[SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[Spec]]
deps = ["Cassette", "Pkg", "Random", "Test"]
git-tree-sha1 = "01317d4b40fe250c4cd07323584070c3d2d82811"
uuid = "b8ccf107-3a88-5e0f-823b-b838c6a0f327"
version = "0.2.0"

[[SpecialFunctions]]
deps = ["OpenSpecFun_jll"]
git-tree-sha1 = "d8d8b8a9f4119829410ecd706da4cc8594a1e020"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "0.10.3"

[[StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "da4cf579416c81994afd6322365d00916c79b8ae"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "0.12.5"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[StatsAPI]]
git-tree-sha1 = "1958272568dc176a1d881acb797beb909c785510"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.0.0"

[[StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "eb35dcc66558b2dda84079b9a1be17557d32091a"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.12"

[[StatsFuns]]
deps = ["ChainRulesCore", "InverseFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "385ab64e64e79f0cd7cfcf897169b91ebbb2d6c8"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "0.9.13"

[[SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[UnicodePlots]]
deps = ["Crayons", "Dates", "SparseArrays", "StatsBase"]
git-tree-sha1 = "f1d09f14722f5f3cef029bcb031be91a92613ae9"
uuid = "b8865327-cd53-5732-bb35-84acbb429228"
version = "2.4.6"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
"""

# ╔═╡ Cell order:
# ╟─daa9fd86-5a36-4aa2-842e-477cdb19b8d5
# ╠═62257a75-2949-4afc-8543-fe3fa4073be5
# ╟─53572568-9d02-465a-baba-1c624d79d4b5
# ╠═f0f80b1a-d090-11eb-2b0d-d11fd8196311
# ╠═49b116d3-dc2f-4e1d-9bff-41131e8148c2
# ╠═4936c45a-a5bf-49cb-bfdc-c05883d5982b
# ╟─57c308fa-a2e7-49fb-b52d-41346ee7ea0d
# ╠═d3af8df6-5375-4a52-9432-41ef6227af0c
# ╠═aa5ea98f-5db3-4de5-89e4-fe1ca27c0157
# ╠═b0769639-7b6a-4d95-bc8d-bdedd5d27c4f
# ╠═8e2fb0c5-ca50-4bcb-85bf-d78c06ea5653
# ╠═ad3ec928-dc20-4987-aaed-78e8c4141d3e
# ╟─87199546-b427-4908-9531-28d40995efa8
# ╠═4b8285ca-0fa8-4c38-a2a9-870169a2c1d7
# ╠═0ed2799b-0e1b-434a-85be-99a3869a89c7
# ╟─505f497c-2852-44f2-bf17-8bfb12886554
# ╠═fc03484c-206d-4c3d-90f9-773e3b9b0a90
# ╟─413d05ce-ed65-406e-be97-32a2bad22d92
# ╠═ff0aced3-466f-44e8-8d84-9521fca7c7c4
# ╟─233e3ee2-e56c-4c4d-a53d-83c144c303d0
# ╠═5774b63a-d492-490e-862a-0c3645722885
# ╟─c6d93cdd-a2bd-4e5b-b835-1509cc582978
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
# ╟─abe64bc4-cdef-4cb5-80cc-2e99e792ecab
# ╠═672b6bfa-54ce-4b12-80f0-ee930a777cbc
# ╠═36a6cb8a-f81e-4e05-9dd0-a475e88ab62c
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
