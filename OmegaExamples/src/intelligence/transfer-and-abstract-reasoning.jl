### A Pluto.jl notebook ###
# v0.20.19

using Markdown
using InteractiveUtils

# ╔═╡ 17aca1ac-d96e-4367-8233-f518826590f7
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

# ╔═╡ b98de567-f00d-42ad-a4e7-85fa35bb78b1
md"""
# 6. Transfer and abstract reasoning

This chapter is a preview of reusing a representation in a different domain.
The planned example will use a small matrix or analogy problem in which a
transformation repeats across rows, while the objects on which it acts change.

The learner will have to identify what carries over: the colours and shapes,
the transformation, or a representation in which the transformation is simple.

## Discussion

Imagine one row that rotates a triangle and another that rotates an arrow.
What can the learner reuse from the first row? Now replace the arrow with a
circle. The same rotation produces no visible difference; how would that affect
what you can infer from the row?

Compare this with permuting coin flips in Chapter 2. The transformation acts
on positions, while the task determines which resulting distinctions matter.
What would count as evidence that a learner transferred that structure rather
than memorised the objects?
"""

# ╔═╡ Cell order:
# ╠═17aca1ac-d96e-4367-8233-f518826590f7
# ╟─b98de567-f00d-42ad-a4e7-85fa35bb78b1
