using Distributions: Multivariate, Distribution, Normal

export Mv

# """
# Multivariate distribution: Random array where each variable is ciid given
# values for parameters.

# `Mv(dist, shape)`

# # Arguments 
# - `dist` a variable class, i.e. `dist(id, ω)` must b defined, e.g. `Normal(0, 1)`
# - `shape` Dimensions of Multivariate

# # Returns

# # Example
# ```julia
# x = 1 ~ Normal(0, 1)
# function f(id, ω)
#   x(ω) + Uniform(0, 1)(id, ω)
# end
# xs = 2 ~ Mv(f, (3, 3))
# randsample((x, xs))
# ```
# """
# struct Mv{T, SHAPE}
#   dist::T
#   shape::SHAPE
# end

# Mv(dist, N::Integer) = Mv(dist, (N,))

# traitlift(::Type{<:Mv}) = Lift()

# # Base.eltype(Mv{T}) where {T} = 


# prim(d::Normal) = StdNormal()

# func(d::Normal, x) = x * d.σ + d.μ

# @inline Var.recurse(mv::Mv{<:Distribution}, id, ω) =
#   map(x -> func(mv.dist, x), resolve(Mv(prim(mv.dist), mv.shape), id, ω))

# f(x::Dims) = map(i->1:i, x)
# g(x::Dims) = Iterators.product(f(x)...)
# @inline Var.recurse(mv::Mv{<:T}, id, ω) where T =
#   map(id_ -> mv.dist(append(id, id_), ω), g(mv.shape))

# Base.rand(rng::AbstractRNG, mv::Mv{<:PrimDist}) = 
#   rand(rng, mv.dist, mv.shape)

struct Mv{IDXS, OP, F}
  idxs::IDXS
  op::OP
  f::F
end
# (mv::Mv)(ω) = map(i -> mv.op(i, mv.f)(ω), mv.idxs)
Var.recurse(mv::Mv, ω) =  map(i -> mv.op(i, mv.f)(ω), mv.idxs)