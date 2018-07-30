defalg(args...) = SSMH
defΩ(args...) = Omega.SimpleΩ{Vector{Int}, Float64}
defcb(args...) = donothing

"Sample `n` from `x`"
function Base.rand(x::RandVar, n::Integer; alg::Algorithm =  defalg(x), ΩT = defΩ(alg), kwargs...)
  rand(x, n, alg, ΩT; kwargs...)
end

"Sample 1 from `x`"
function Base.rand(x::RandVar; alg::Algorithm = defalg(x), ΩT = defΩ(alg), kwargs...)
  first(rand(x, 1, alg, ΩT, kwargs...))
end

Base.rand(x::RandVar, y::RandVar, n; kwargs...) = rand(cond(x, y), n; kwargs...)
Base.rand(x::RandVar, y::RandVar; kwargs...) = rand(cond(x, y); kwargs...)

Base.rand(x::UTuple{RandVar}, n::Integer; kwargs...) = rand(randtuple(x), n; kwargs...)
Base.rand(x::UTuple{RandVar}; kwargs...) = rand(randtuple(x); kwargs...)