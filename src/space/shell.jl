# "Omega with some metadata"
abstract type ShellΩ{I,ΩT} <: Ω{I} end

"`shell(ω, someshellω)` wraps ω with metadata of `someshellω`"
function shell end

# proj(sω::ShellΩ, rv::RandVar) = shell(proj(sω.ω, rv), sω)
# Space.parentω(sπω::ShellΩ{I, <: ΩProj}) where I = shell(parentω(sπω.ω), sπω)

# @inline apl(rv::RandVar, sπω::ShellΩ{I, <: ΩProj}) where I = apl(rv, parentω(sπω))
# @inline apl(rv::RandVar, sω::ShellΩ{I, <: ΩBase}) where I =  ppapl(rv, proj(sω, rv))

Base.getindex(sπω::ShellΩ{I, <: ΩProj}, i) where I = shell(Base.getindex(sπω.ω, i), sπω)
Base.rand(sω::ShellΩ, dims::Dims) = Base.rand(sω.ω, dims) 
Base.rand(sω::ShellΩ, arr::Array) = Base.rand(sω.ω, arr) 
Base.rand(sω::ShellΩ, T) = Base.rand(sω.ω, T) 
Base.rand(sω::ShellΩ, ::Type{T}) where T = Base.rand(sω.ω, T) 

@inline rng(sω::ShellΩ) = rng(sω.ω)