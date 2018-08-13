"`RandVar` identically distributed to `f` but conditionally independent given parents`"
ciid(f; T = infer_elemtype(f)) = URandVar{T}(f, ())

"`RandVar` identically distributed to `x` but conditionally independent given parents`"
ciid(x::T) where T <: RandVar =  T(params(x)..., uid())

"ciid with arguments"
ciid(f, args...; T = infer_elemtype(reifyapply, f, args...)) =
  URandVar{T}(reifyapply, (f, args...))

@inline reifyapply(ωπ, f, args...) = f(reify(ωπ, args)...)
@inline reifyapply(ωπ, f) = f(ωπ)