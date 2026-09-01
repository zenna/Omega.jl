### A Pluto.jl notebook ###
# v0.20.19

using Markdown
using InteractiveUtils

# ╔═╡ 5c087951-0dde-4851-9bef-a43e41f9e232
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

# ╔═╡ 6c41a571-c59c-4371-8a1b-d16acb259f07
md"""
# 3. Inferring Normal Forms

Chapter 1 introduces a generative world, tasks, and task-sufficient representations. Chapter 2 introduces generators, their orbits, and quotient representations. This chapter will combine those ingredients by treating a normal form as a canonical coordinate for a task-relevant quotient and inferring which candidate normal form fits the task.

The worked example will continue to use ordered coin-flip sequences. It will compare normal forms induced by a supplied library of transformations, such as the identity, reversal, and adjacent swaps. Omega will represent uncertainty over these candidates and condition that uncertainty on whether each normal form preserves the chosen task.

## TODO

- [ ] Define the finite library of candidate generators and their induced normal forms.
- [ ] Connect each normal form to its orbit and quotient representation.
- [ ] Define task sufficiency by checking whether the task remains constant within each quotient class.
- [ ] Infer task-sufficient normal forms with Omega.
- [ ] Compare the fair-coin posterior task, which depends only on head count, with the longest-head-run task, which depends on order.
- [ ] Add an explicit simplicity preference over task-sufficient candidates and identify it as an example-specific modelling choice.
- [ ] Show how incomplete evidence preserves uncertainty over several normal forms.
- [ ] State the boundary between selecting from a supplied library and inventing new generators or representations.

The implementation will reuse the world and tasks from Chapter 1 and the generator-to-quotient construction from Chapter 2 instead of introducing a separate geometric example.
"""

# ╔═╡ Cell order:
# ╠═5c087951-0dde-4851-9bef-a43e41f9e232
# ╟─6c41a571-c59c-4371-8a1b-d16acb259f07
