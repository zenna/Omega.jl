### A Pluto.jl notebook ###
# v0.20.19

using Markdown
using InteractiveUtils

# ╔═╡ 4af644ea-ae6a-48ce-b3d9-22986572c733
begin
    import Pkg
	# Pkg.activate(mktempdir())
 #    repo = "https://github.com/zenna/Omega.jl"
 #    rev = "complete-probmods"
	# Pkg.add([
 #        Pkg.PackageSpec(url=repo, rev=rev),
 #        Pkg.PackageSpec(url=repo, rev=rev, subdir="OmegaCore"),
 #        Pkg.PackageSpec(url=repo, rev=rev, subdir="InferenceBase"),
 #        Pkg.PackageSpec(url=repo, rev=rev, subdir="SoftPredicates"),
 #        Pkg.PackageSpec(url=repo, rev=rev, subdir="connectors/OmegaDistributions"),
 #        Pkg.PackageSpec(url=repo, rev=rev, subdir="connectors/OmegaSoftPredicates"),
 #        Pkg.PackageSpec(url=repo, rev=rev, subdir="OmegaMH"),
 #        Pkg.PackageSpec(url=repo, rev=rev, subdir="ReplicaExchange"),
 #        Pkg.PackageSpec(url=repo, rev=rev, subdir="OmegaExamples"),
 #    ])
	Pkg.activate(Base.current_project())
    using Omega, Distributions, OmegaExamples, UnicodePlots
end

# ╔═╡ af30ec1c-dcc4-4034-af27-277646e90e4c
md"""
# 5. Representational revision

This chapter is a preview of revising a representation when the task changes.
Chapter 1 gives a concrete starting point: a head count answers the coin question,
but two sequences with that count can have different longest head runs.

The planned example will start with that count representation and introduce a
new task. It will use the conflicting answers to update beliefs over a supplied
library of representations, including ones that retain order.

## Discussion

Use `HHHT` and `HTHH` from Chapter 1. What observation tells you that the count
representation has become insufficient? Would adding the longest head run to the
stored count solve the new task? What question would still require the sequence?

Changing the task can reveal distinctions that were previously irrelevant.
Which transformations from Chapter 2 remain harmless after this task change?
The worked example will use that question to connect revising a representation
with revising its available transformations.
"""

# ╔═╡ Cell order:
# ╠═4af644ea-ae6a-48ce-b3d9-22986572c733
# ╟─af30ec1c-dcc4-4034-af27-277646e90e4c
