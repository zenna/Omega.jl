export Mv, manynth, dimsnth

"""
Multivariate distribution from class: Random array where each variable is ciid given
values for parameters.

`Mv(ids, class)`

# Arguments 
- `ids` Collection of ids
- `f` a variable class, i.e. `f(id, ω)` must be defined, e.g. `~ Normal(0, 1)`

# Returns
- Random variable: `ω -> [x(i, ω), x(i+1, ω), ..., x(n, ω)]` for all `i` in `ids`

# Example
```jldoctest
x = 1 ~ Normal(0, 1)
function f(id, ω)
  x(ω) + Uniform(0, 1)(id, ω)
end
xs = 2 ~ Mv(f, (3, 3))
randsample((x, xs))
```
"""
struct Mv{IDS, FS} <:  AbstractVariable
  ids::IDS
  f::FS
end

Var.recurse(mv::Mv, ω) =  map(i -> mv.f(i, ω), mv.ids)

"`manynth(f, ids)` - shorthand for `Mv(ids, f)` See also: [`Mv`](@ref)"
@inline manynth(f, ids) = Mv(ids, f)

"`dimsnth(f, shape::Dims)` Like [`manynth`](@ref), but `shape` is a tuple of dimensions"
@inline dimsnth(f, shape::Dims) = Mv(CartesianIndices(shape), f)