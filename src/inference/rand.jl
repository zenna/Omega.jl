UTuple{T} = Tuple{Vararg{T, N}} where N

"Unconditional Sample from `x`"
Base.rand(x::UTuple{RandVar}) = x(DirtyOmega())

"Unconditional Sample from `x`"
Base.rand(x::RandVar) = x(DirtyOmega())