defalg(args...) = SSMH
defΩ(args...) = Omega.SimpleΩ{Vector{Int}, Omega.ValueTuple}
defcb(args...) = donothing

"Sample `n` from `x`"
function Base.rand(x::RandVar, n::Integer; alg::Algorithm =  defalg(x), cb = defcb(alg), ΩT = defΩ(alg))
  rand(x, n, alg, ΩT, cb)
end

"Sample 1 from `x`"
function Base.rand(x::RandVar; alg::Algorithm = defalg(x), cb = defcb(alg), ΩT = defΩ(alg))
  first(rand(x, 1, alg, ΩT, cb))
end

Base.rand(x::RandVar, y::RandVar, n; kwargs...) = rand(cond(x, y), n; kwargs...)
Base.rand(x::RandVar, y::RandVar; kwargs...) = rand(cond(x, y); kwargs...)

Base.rand(x::UTuple{RandVar}, n::Integer; kwargs...) = rand(randtuple(x), n; kwargs...)
Base.rand(x::UTuple{RandVar}; kwargs...) = rand(randtuple(x); kwargs...)