UTuple{T} = Tuple{Vararg{T, N}} where N
RandVars{T} = Union{RandVar{T}, UTuple{RandVar{T}}}

"Unconditional Sample from `x`"
Base.rand(x::UTuple{RandVar}) = x(DirtyOmega())

"Unconditional Sample from `x`"
Base.rand(x::RandVar) = x(DirtyOmega())