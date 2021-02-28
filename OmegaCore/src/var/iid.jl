export iid,  <|, <|ⁿ

struct IID{F, I}
  i::I
  f::F
end

"""
`iid(f::RandVar, i)`

Independent raandom variables
# Input
- `x` - Variable
- `i` - index

# Returns 
idth variable in sequence `(x1, x2, ...)`` which are all mutually independent
"""
iid(f, i) = IID(i, f)

(x::IID)(ω) = x.f(Basis.proj(ω, x.i))

@inline i <| f = iid(f, i)

## Multivariate
idxs <|ⁿ f = Mv(idxs, <|, f)
# (mv::Mv)(ω) = map(i -> mv.op(i, ω), m.idxs)