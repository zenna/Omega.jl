import Omega.Space: ShellΩ, shell

# No Tracking

"Ignore all `cond` statements"
struct IgnoreCondΩ{I, ΩT} <: ShellΩ{I, ΩT}
  ω::ΩT
  IgnoreCondΩ(ω::ΩT) where {I, ΩT <: Ω{I}} = new{I, ΩT}(ω)
end
Omega.shell(ω, ::IgnoreCondΩ) = IgnoreCondΩ(ω)

condf(ω::IgnoreCondΩ, x, y) = x(ω)

"Is `ω` in the domain of `x`?"
applynotrackerr(x, ω) = x(IgnoreCondΩ(ω))

# Tracking
"Omega which keeps track of error `err`"
struct ErrΩ{I, ΩT, SB <: AbstractSoftBool} <: ShellΩ{I, ΩT}
  ω::ΩT
  err::Base.RefValue{SB}
  ErrΩ(ω::ΩT, sb::SB) where {I, ΩT <: Ω{I}, SB} = new{I, ΩT, SB}(ω, Ref(sb))
  ErrΩ(ω::ΩT, sb::Base.RefValue{SB}) where {I, ΩT <: Ω{I}, SB} = new{I, ΩT, SB}(ω, sb)
end

using ZenUtils
Omega.shell(ω, eω::ErrΩ) = ErrΩ(ω, eω.err)

# # General Wrapping
# proj(eω::ErrΩ, rv::RandVar) = ErrΩ(proj(eω.ω, rv), eω.err)

# # General wrapping
# Space.parentω(eπω::ErrΩ{I, <: ΩProj}) where I = ErrΩ(parentω(eπω.ω), eπω.err)

# @inline apl(rv::RandVar, eπω::ErrΩ{I, <: ΩProj}) where I = apl(rv, parentω(eπω))
# @inline apl(rv::RandVar, eω::ErrΩ{I, <: ΩBase}) where I =  ppapl(rv, proj(eω, rv))

# Base.getindex(eω::ErrΩ, i) = Base.getindex()
# Base.getindex(eπω::ErrΩ{I, <: ΩProj}, i) where I = ErrΩ(Base.getindex(eπω.ω, i), eπω.err)
# Base.rand(eω::ErrΩ, dims::Dims) = Base.rand(eω.ω, dims) 
# Base.rand(eω::ErrΩ, arr::Array) = Base.rand(eω.ω, arr) 
# Base.rand(eω::ErrΩ, T) = Base.rand(eω.ω, T) 
# Base.rand(eω::ErrΩ, ::Type{T}) where T = Base.rand(eω.ω, T) 

# @inline rng(eω::ErrΩ) = rng(eω.ω)

function condf(eω::ErrΩ, x, y)
  res = y(eω)
  conjoinerror!(eω, res)
  x(eω)
end

cond(eω::ErrΩ, bool) = conjoinerror!(eω, bool)
conjoinerror!(eω::ErrΩ, b) = eω.err[] &= b

"Is `ω` in the domain of `x`?"
function applytrackerr(x, ω, errinit = softtrue())
  ω_ = ErrΩ(ω, errinit)
  fx = apl(x, ω_)
  (fx = fx, err = ω_.err)
end

"Soft `indomain`: distance from `ω` to the domain of `x`"
indomainₛ(x, ω, errinit = softtrue()) = applytrackerr(x, ω, errinit).err.x
indomainₛ(x::RandVar) = ciid(ω -> indomainₛ(x, ω))

"Is `ω` in the domain of `x`?"
indomain(x, ω, errinit = true) = applytrackerr(x, ω, errinit).err.x
indomain(x::RandVar) = ciid(ω -> indomain(x, ω))




# Either make default fail
# Have no default

# "Omega which keeps track error"
# struct ErrΩ{I, ΩT, SB} <: Ω{I}
#   ω::ΩT
#   elem::Base.RefValue{SB}
# # end


# conjoinerror!(sbw::Wrapper{<: AbstractSoftBool}, y::Nothing) = nothing
# conjoinerror!(sbw::Wrapper{<: AbstractSoftBool}, yω::AbstractSoftBool) = sbw.elem &= yω
# function conjoinerror!(sbw::Wrapper{<: AbstractSoftBool}, yω::Bool)
#   if yω
#     conjoinerror!(sbw, softtrue())
#   else
#     conjoinerror!(sbw, softfalse())
#   end
# end
# conjoinerror!(wrap::Wrapper{Bool}, yω::SoftBool) = conjoinerror!(wrap, Bool(yω))
# conjoinerror!(wrap::Wrapper{Bool}, yω::Bool) = wrap.elem &= yω



# # Tagged Omega Tracking
# mutable struct Wrapper{T}
#   elem::T
# end

# conjoinerror!(sbw::Wrapper{<: AbstractSoftBool}, y::Nothing) = nothing
# conjoinerror!(sbw::Wrapper{<: AbstractSoftBool}, yω::AbstractSoftBool) = sbw.elem &= yω
# function conjoinerror!(sbw::Wrapper{<: AbstractSoftBool}, yω::Bool)
#   if yω
#     conjoinerror!(sbw, softtrue())
#   else
#     conjoinerror!(sbw, softfalse())
#   end
# end
# conjoinerror!(wrap::Wrapper{Bool}, yω::SoftBool) = conjoinerror!(wrap, Bool(yω))
# conjoinerror!(wrap::Wrapper{Bool}, yω::Bool) = wrap.elem &= yω

function condf(tω::TaggedΩ, x, y)
  if haskey(tω.tags, :err)
    res = y(tω)
    conjoinerror!(tω.tags.err, res)
    x(tω)
  else
  end
end

"Tag `ω` with `err`" 
tagerror(ω, errinit::AbstractSoftBool = softtrue()) = tag(ω, (err = Ref(errinit),))

# function cond(tω::TaggedΩ, bool)
#   conjoinerror!(tω.tags.err, bool)
# end

# tagerror(ω, wrap) = tag(ω, (err = wrap,))

# "Is `ω` in the domain of `x`?"
# function applytrackerr(x, ω, wrap = Wrapper(softtrue()))
#   ω_ = tagerror(ω, wrap)
#   fx = x(ω_)
#   (fx, ω_.tags.err.elem)
# end

# "Soft `indomain`: distance from `ω` to the domain of `x`"
# indomainₛ(x, ω, wrap = Wrapper{SoftBool}(softtrue())) = applytrackerr(x, ω, wrap)[2]
# indomainₛ(x::RandVar) = ciid(ω -> indomainₛ(x, ω))

# "Is `ω` in the domain of `x`?"
# indomain(x, ω, wrap = Wrapper{Bool}(true)) = applytrackerr(x, ω, wrap)[2]
# indomain(x::RandVar) = ciid(ω -> indomain(x, ω))


# "Is `ω` in the domain of `x`?"
# applynotrackerr(x, ω, wrap = Wrapper{SoftBool}(softtrue())) = x(tagerror(ω, wrap))  # FIXME: This could be made more efficient but actually not tracking