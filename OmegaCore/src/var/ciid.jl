export  ciidn, ciid

# # Conditional Independence
# It is useful to create independent and conditionally independent random variables
# This has meaning for both random and free variables
struct CIID{F, P}
  f::F
  p::P
end

"""
`ciid(f, p)`

`id`th member of exchangeable sequence `(f_1, f_2, ..., f_n)`

Each element `f_i` is Conditionally independent of all other `f_j` given parents
"""
@inline ciid(f, p) = @error("unimplemented")

# ciidn(f, ids) = Mv(ids, ~, f)
