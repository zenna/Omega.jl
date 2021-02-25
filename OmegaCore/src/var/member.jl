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

@inline Var.recurse(x::Member, ω) = x.class(x.id, ω)

"""
`ciid(f, id)`

`id`th member of exchangeable sequence `(f_1, f_2, ..., f_n)`

Each element `f_i` is Conditionally independent of all other `f_j` given parents
"""
@inline ciid(f, id) = Member(id, f)   

"`id ~ f` is an alias for `ciid(f, i)`"
@inline Base.:~(id, f) = ciid(f, id)

## Display
Base.show(io::IO, x::Member) = print(io, x.id,"@",x.class)

