"Parameter Set"
struct Params{I, T}
  d::Dict{I, T}
end

Params() = Params{Symbol, Any}(Dict{Symbol, Any}())
Base.getindex(θ::Params{I}, i::I) where I = θ.d[i]
"Set default value"
Base.getindex(θ::Params{I}, i::I, v) where I = θ.d[i] = v
Base.setindex!(θ::Params{I}, v, i::I) where I = θ.d[i] = v 

function mem(ω::Omega, ::Params)
end

## TODO: Saving / loading.  Use BSON!

save(ω::Omega, fname) = bson(fname, ω)


"Params sample. Any `val` which is a `RandVar` in `φ` are sampled"
function Base.rand(ω::Omega, φ::Params)
  Params(Dict(k => apl(v, ω) for (k, v) in φ.d))
end 

Base.rand(φ::Params) = rand(DefaultOmega(), φ)

# TODO: Stable IDs from Omega
# Problem 1.  [@id] is global, but it need only be relative (maybe?!)
# Problem 2. randvar ids are global

"RandVar which has randomness memoized"
struct MemoizedRandVar{O, X}
  ω::O
  x::X
end

Base.show(io::IO, φ::Params) = show(io, φ.d)
Base.display(φ::Params) = (println("Params"); display(φ.d))