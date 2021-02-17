using ..Tagging, ..IDS, ..Traits

export Member
# export ~, ciid, Member

# # Conditional Independence
# It is useful to create independent and conditionally independent random variables
# This has meaning for both random and free variables

"The `id`th member of the family `f`"
struct Member{F, ID}
  id::ID
  class::F
end

Base.:(==)(m1::Member, m2::Member) =
  m1.id == m2.id && m1.class == m2.class

Base.hash(x::Member) = hash(x.id)

# @inline (x::Member)(ω) = x.f(appendscope(ω, x.id))
@inline Var.recurse(x::Member, ω) = x.class(x.id, ω)

Base.show(io::IO, x::Member) = print(io, x.id,"@",x.class)

"""
Conditionally independent copy of `f`

if `g = ciid(f, id)` then `g` will be identically distributed with `f`
but conditionally independent given parents.
"""
@inline ciid(f, id) = Member(id, f)   
@inline ciid(f, id::Integer, τ::Type{T} = defID()) where T =
  ciid(f, singletonid(T, id))

"`id ~ f` is an alias for `ciid(f, i)`"
@inline Base.:~(id, f) = ciid(f, id)
