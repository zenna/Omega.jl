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


maybereplace(x::RandVar, replmap) = replace(x, replmap)

# If x is a constant, do nothing
maybereplace(x, replmap) = x

# Params of intervened RandVar should themselves be intervened (if not const)
params(rv::ReplaceRandVar) = map(p -> maybereplace(p, rv.replmap), params(rv.x))

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

# """`replace(x::RandVar, replmap)`
# Causal intervention.

# Returns a randvar that is like `x` but where random variables it depend on
# (its parents) are changed to those specified in replmap

# ```julia
# θ = normal(0, 1)
# x = normal(θ, 1)
# xdo1 = replace(x, θ => 100.0)
# xdo2 = replace(x, θ => uniform(1000.0, 2000.0))
# rand((x, xdo1, xdo2))
# ```

# """
# function Base.replace end

"Causal Intervention: Set `θold` to `θnew` in `x`"
Base.replace(x::RandVar, replmap::Dict{Int, <: RandVar}) = ReplaceRandVar(x, replmap)
@spec :nocheck all([isparent(theta, x) for theta in values(tochange)])

"Causal Intervention: Set `θold` to `θnew` in `x`"
Base.replace(x::RandVar, tochange::Union{Dict, Pair}...) = replace(x, upconv(tochange...))

## Show
Base.show(io::IO, rv::ReplaceRandVar) = 
  (print(io, rv.x); print(io, " | intervened "))