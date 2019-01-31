# Causal Intervention (using TaggedΩ) #
"Intervened Random Variable x | do(theta)"
struct ReplaceRandVar{R1 <: RandVar, R2 <: RandVar} <: RandVar
  x::R1                     # Intervened Random Variable
  replmap::Dict{ID, R2}     # Intervention map
  id::ID
  ReplaceRandVar(rv::R22, replmap::Dict{ID, T2}, id = uid()) where {R22 <: RandVar, T2 <: RandVar} = 
    new{R22, T2}(rv, replmap, id)
end
@inline (rv::ReplaceRandVar)(ω::Ω) = apl(rv, ω)
id(x::ReplaceRandVar) = x.id
ppapl(rv::ReplaceRandVar, ω::Ω) = apl(rv.x, tag(ω, (replmap = rv.replmap,)))
params(rv::ReplaceRandVar) = map(p -> replace(p, rv.replmap), params(rv.x))

@inline function replaceapl(rv::RandVar, tω::TaggedΩ{I, Tags{K, V}, ΩT}) where {I, K, V, ΩT <: ΩBase}
  if haskey(tω.tags.replmap, rv.id) # FIXME, double look up
    apl(tω.tags.replmap[rv.id], tω) # FIXME: add Type constriant!
  else
    ppapl(rv, proj(tω, rv))
  end
end

# Conversions #
mcv(x::RandVar) = x
mcv(x) = constant(x)
upconv(x::Dict{RV}) where RV = Dict(k.id => mcv(v) for (k, v) in x)
upconv(pairs::Pair...) = Dict(k.id => mcv(v) for (k, v) in pairs)
upconv(pair::Pair) = Dict(pair.first.id => mcv(pair.second))

"Causal Intervention: Set `θold` to `θnew` in `x`"
Base.replace(x::RandVar, replmap::Dict{Int, <: RandVar}) = ReplaceRandVar(x, replmap)
@spec :nocheck all([isparent(theta, x) for theta in values(tochange)])

"Causal Intervention: Set `θold` to `θnew` in `x`"
Base.replace(x::RandVar, tochange::Union{Dict, Pair}...) = replace(x, upconv(tochange...))

## Show
Base.show(io::IO, rv::ReplaceRandVar) = 
  (print(io, rv.x); print(io, " | intervened "))