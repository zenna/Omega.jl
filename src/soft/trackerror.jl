# Issue is that type of err value depends on
# gradient method used
# Solutions
# Specialize: indomain/applytrackerr based on type of Omega

conjoinerror!(err::Ref{<:Real}, b) = err[] &= b

"Is `ω` in the domain of `x`?"
function applytrackerr(x, ω, errinit = softtrue())
  ω_ = tagerror(ω, errinit) # zt: surprisingly expensive
  fx = apl(x, ω_)
  (fx = fx, err = ω_.tags.err.x)
end

tagnotrackerr(ω) = tag(ω, (donttrack = true,))
applynotrackerr(x, ω) = apl(x, tagnotrackerr(ω))

"Soft `indomain`: distance from `ω` to the domain of `x`"
indomainₛ(x, ω, errinit = softtrue()) = applytrackerr(x, ω, errinit).err
indomainₛ(x::RandVar) = ciid(ω -> indomainₛ(x, ω))

"Is `ω` in the domain of `x`?"
indomain(x, ω, errinit = true) = applytrackerr(x, ω, errinit).err
indomain(x::RandVar) = ciid(ω -> indomain(x, ω))

function Omega.condf(tω::TaggedΩ, x, y)
  if !haskey(tω.tags, :donttrack) && haskey(tω.tags, :err)
    conjoinerror!(tω.tags.err, apl(y, tω))
  end
  apl(x, tω)
end

function Omega.cond(tω::TaggedΩ, bool)
  if !haskey(tω.tags, :donttrack) && haskey(tω.tags, :err)
    conjoinerror!(tω.tags.err, bool)
  end
end

"Tag `ω` with `err`" 
# tagerror(ω, errinit::AbstractBool) = tag(ω, (err = Ref(errinit),)) #FIXME UNCOMMENT THIS AND SPECIALISE BELOW TO OMEGA
tagerror(ω, errinit::AbstractBool) = tag(ω, (err = Ref{Real}(errinit),))

"Tag tω with error"
function tagerror(tω::TaggedΩ, errinit::AbstractBool)
  # If error already there, use that!
  haskey(tω.tags, :err) ? tω : tag(tω, (err = Ref{Real}(errinit),))
end