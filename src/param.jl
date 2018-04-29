"Parameter Set"
struct Params{I, T}
  d::Dict{I, T}
end

Base.values(φ::Params) = values(φ.d)
Base.keys(φ::Params) = keys(φ.d)
Base.get(φ::Params, k, v) = get(φ.d, k, v)
Base.get!(φ::Params, k, v) = get!(φ.d, k, v)
Params() = Params{Symbol, Any}(Dict{Symbol, Any}())
Base.getindex(θ::Params{I}, i::I) where I = θ.d[i]
"Set default value"
Base.setindex!(θ::Params{I}, v, i::I) where I = θ.d[i] = v 

"""Product space of `Param` from  product of values(φ)

```jldoctest
julia> φ = Params(Dict(:a => [1,2,3], :b => ["x", "y"]))
Params
Dict{Symbol,Any} with 2 entries:
  :a => [1, 2, 3]
  :b => String["x", "y"]

julia> length(prod(φ))
6
```
"""
function Base.prod(toenum::Params)
  q = Base.Iterators.product(values(toenum)...)
  (Params(Dict(zip(keys(toenum), v))) for v in q)
end

## IO
##
## TODO: Saving / loading.  Use BSON!
save(ω::Omega, fname) = bson(fname, ω)

"Params sample. Any `val` which is a `RandVar` in `φ` are sampled"
function Base.rand(ω::Omega, φ::Params)
  Params(Dict(k => apl(v, ω) for (k, v) in φ.d))
end

function (φ::Params)(ω::Omega)
  Params(Dict(k => apl(v, ω) for (k, v) in φ.d))
end
Base.rand(ω, φ::Params) = φ(ω)
Base.rand(φ::Params) = Base.rand(DefaultOmega(), φ)

## Show
## ====
"Turn a key value into command line argument"
function stringify(k, v)
  if v == true
    "--$k"
  elseif v == false
    ""
  else
    "--$k=$v"
  end
end

function linearstring(d::Dict, ks::Symbol...)
  join([string(k, "_", d[k]) for k in ks], "_")
end

Base.show(io::IO, φ::Params) = show(io, φ.d)
Base.display(φ::Params) = (println("Params"); display(φ.d))