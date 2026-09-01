### A Pluto.jl notebook ###
# v0.20.19

using Markdown
using InteractiveUtils

# ╔═╡ 4af644ea-ae6a-48ce-b3d9-22986572c733
begin
    import Pkg
	Pkg.activate(mktempdir())
    repo = "https://github.com/zenna/Omega.jl"
    rev = "complete-probmods"
	Pkg.add([
        Pkg.PackageSpec(url=repo, rev=rev),
        Pkg.PackageSpec(url=repo, rev=rev, subdir="OmegaCore"),
        Pkg.PackageSpec(url=repo, rev=rev, subdir="InferenceBase"),
        Pkg.PackageSpec(url=repo, rev=rev, subdir="SoftPredicates"),
        Pkg.PackageSpec(url=repo, rev=rev, subdir="connectors/OmegaDistributions"),
        Pkg.PackageSpec(url=repo, rev=rev, subdir="connectors/OmegaSoftPredicates"),
        Pkg.PackageSpec(url=repo, rev=rev, subdir="OmegaMH"),
        Pkg.PackageSpec(url=repo, rev=rev, subdir="ReplicaExchange"),
        Pkg.PackageSpec(url=repo, rev=rev, subdir="OmegaExamples"),
    ])
    using Omega, Distributions, OmegaExamples, UnicodePlots
end

# ╔═╡ af30ec1c-dcc4-4034-af27-277646e90e4c
md"""
# 5. Representational Revision

This chapter will begin with a representation that is sufficient for one task and then change the task so that the same representation fails. The learner will condition over a revised representation library instead of treating its first coordinate system as permanent.

The chapter will show how to:

- diagnose a representation failure after a task change;
- revise uncertainty over candidate representations;
- study how a revised representation can expose new lawful generators.

The worked model will keep selection from a supplied library distinct from unrestricted invention of new representations.
"""

# ╔═╡ Cell order:
# ╠═4af644ea-ae6a-48ce-b3d9-22986572c733
# ╟─af30ec1c-dcc4-4034-af27-277646e90e4c
