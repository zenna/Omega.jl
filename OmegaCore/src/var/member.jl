using ..Tagging, ..IDS, ..Traits

export Member, nth

"The `id`th member of the family `f`"
struct Member{F, ID} <: AbstractVariable
  id::ID
  class::F
end

Base.:(==)(m1::Member, m2::Member) =
  m1.id == m2.id && m1.class == m2.class

Base.hash(x::Member) = hash(x.id)

@inline Var.recurse(x::Member, ω) = x.class(x.id, ω) 

"""
`nth(f, id)`

`id`th member of sequence `(f_1, f_2, ..., f_n)`

Each element `f_i` is Conditionally independent of all other `f_j` given parents
"""
@inline nth(f, id) = Member(id, f)

"`id ~ f` is an alias for `nth(f, i)`"
@inline Base.:~(id, f) = nth(f, id)

@inline Base.:~(f) = Var.Class(f)

## Display
Base.show(io::IO, x::Member) = print(io, x.id,"@",x.class)

