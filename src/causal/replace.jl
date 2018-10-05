# Causal Intervention (using TaggedΩ)

"Intervened Random Variable x | do(theta)"
struct ReplaceRandVar{R1 <: RandVar, R2 <: RandVar} <: RandVar
  x::R1                     # Intervend Random Variable
  replmap::Dict{ID, R2}     # Intervention map
  id::ID
  ReplaceRandVar(rv::R22, replmap::Dict{ID, T2}, id = uid()) where {R22 <: RandVar, T2 <: RandVar} = 
    new{R22, T2}(rv, replmap, id)
end
@inline (rv::ReplaceRandVar)(ω::Ω) = apl(rv, ω)
id(x::ReplaceRandVar) = x.id

params(rv::ReplaceRandVar) = map(p -> replace(p, rv.replmap), params(rv.x))

# Use generated funtion to get typed dispatch on different tags
@generated function apl(rv::RandVar, tω::TaggedΩ{I, Tags{K, V}, ΩT}) where {I, K, V, ΩT <: ΩBase}
  if hastags(tω, :replmap)
    quote
    if id(rv) ∈ keys(tω.tags.tags.replmap) 
      return tω.tags.tags.replmap[rv.id](tω)
    else
      tω_ = maybetag(rv, tω)
      ppapl(rv, proj(tω_, rv))
    end
    end
  else
    quote
    tω_ = maybetag(rv, tω)
    ppapl(rv, proj(tω_, rv))
    end
  end
end

maybetag(rv::ReplaceRandVar, ω::Ω) = tag(ω, (replmap = rv.replmap,))
maybetag(rv::RandVar, ω::Ω) = ω # tag(ω, (replmap = rv.replmap,))

apl(rv::ReplaceRandVar, ω::ΩBase) = rv.x(tag(ω, (replmap = rv.replmap,)))
ppapl(rv::ReplaceRandVar, ωpi) = rv.x(ωpi)

## Conversion
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