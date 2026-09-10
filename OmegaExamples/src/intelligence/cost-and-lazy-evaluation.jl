### A Pluto.jl notebook ###
# v0.20.19

using Markdown
using InteractiveUtils

# ╔═╡ 3fb8eb04-a663-447c-8a3a-bae862cb7cee
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

# ╔═╡ d4831179-822b-4876-9427-46b3296f9106
md"""
# 4. Cost and lazy evaluation

This chapter is a preview of how to compare the computation required by different
representations. A lazy world constructs primitive random values when a query
requests them. A query about the first coin flip may therefore request fewer
values than a query about the longest head run.

The planned example will inspect which primitive values each query requests,
then compare that count with runtime and representation size. These measure
different things: counting dependencies does not count every Julia operation.

## Discussion

Look back at Chapter 1's sequence and count decoders. Which operations do you
repeat when answering another coin query? Which can you reuse if you store the
count? Would your answer change if the next task asks about head runs?

Choose a cost you care about: stored values, requested random values, or elapsed
time. How might two representations rank differently under those choices?
The worked example will make that choice explicit before comparing costs.
"""

# ╔═╡ Cell order:
# ╠═3fb8eb04-a663-447c-8a3a-bae862cb7cee
# ╟─d4831179-822b-4876-9427-46b3296f9106
