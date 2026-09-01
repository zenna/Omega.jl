### A Pluto.jl notebook ###
# v0.20.19

using Markdown
using InteractiveUtils

# ╔═╡ 3fb8eb04-a663-447c-8a3a-bae862cb7cee
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

# ╔═╡ d4831179-822b-4876-9427-46b3296f9106
md"""
# 4. Cost and Lazy Evaluation

This chapter will connect representational simplicity to computation. Omega constructs primitive random values only when a query requests them, making it possible to compare representations by realised dependencies as well as runtime or description length.

The chapter will show how to:

- inspect which primitive variables a task requests from a lazy Omega world;
- distinguish lazy world construction from universal lazy evaluation of Julia code;
- define and compare explicit task-relative simplicity measures.

Laziness can avoid irrelevant computation, but it does not remove the difficulty of inference. The chosen cost will remain a modelling assumption rather than a universal measure supplied by the theory.
"""

# ╔═╡ Cell order:
# ╠═3fb8eb04-a663-447c-8a3a-bae862cb7cee
# ╟─d4831179-822b-4876-9427-46b3296f9106
