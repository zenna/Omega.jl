# Random Variable Application
"Project ω to `x`"
proj(ω::ΩBase, x::RandVar) = ω[x.id]

apl(x, ω::Ω) = x
apl(x::RandVar, ω::Ω) = x(ω)

"`ΩBase` and Tagged `ΩBase`"  
ΩBaseGroup{I, T, ΩT} = Union{ΩBase, TaggedΩ{I, T, ΩT}} where {ΩT <: ΩBase}

@inline apl(rv::RandVar, ω::ΩBaseGroup) =  fapl(rv, proj(ω, rv))

"Reproject back to parent random variable"
@inline apl(rv::RandVar, πω::ΩProj) = rv(parentω(πω))

"Reify arguments (resolve random variables to values)"
@inline reify(ω, args) = map(x -> apl(x, ω), args)

# "Reify random variable args.. i.e. map(x -> apl(x, ω), args)"
# @generated function reify(ω, args)
#   if any(isa.(args RandVar))
#     map(t -> t isa RandVar, args)
#     quote
#       (apl(x, ))
#     end
#   else
#     quote
#       args
#     end
#   end
# end

@inline apl(rv::RandVar, tω::TaggedΩ{I, T, ΩT}) where {I, T, ΩT <: ΩProj}  =
  rv(TaggedΩ(parentω(tω.taggedω), tω.tags))