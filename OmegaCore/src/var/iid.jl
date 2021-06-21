export iid,  <|, <|ⁿ

struct IID{F}
  f::F
end

"""
`iid(f::Var)`

Sequence of independent raandom variables.
# Input
- `f` - Variable

# Returns 
Sequence `(x1, x2, ...)`` which are all mutually independent
"""
@inline iid(f) = IID(f)

@inline (x::IID)(i, ω) = x.f(Basis.proj(ω, i))

# @inline i <| f = iid(f, i)
# ## Multivariate
# idxs <|ⁿ f = Mv(idxs, <|, f)
# (mv::Mv)(ω) = map(i -> mv.op(i, ω), m.idxs)