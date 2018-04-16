UTuple{T} = Tuple{Vararg{T, N}} where N
RandVars{T} = Union{RandVar{T}, UTuple{RandVar{T}}}

"Unconditional Sample from `x`"
Base.rand(x::UTuple{RandVar}, OmegaT = DirtyOmega) = x(OmegaT())

"Unconditional Sample from `x`"
Base.rand(x::RandVar, OmegaT = DirtyOmega) = x(OmegaT())