# Random Variable Application #

"Post-projection application"
function ppapl end

"Apply function to argument"
function apl end

"Apply if randvar otherwise just return value (treat as constant randvar"
subapl(x, ω) = x
@inline subapl(rv::RandVar, ω) = apl(rv, ω)

"Project ω to `x`"
proj(ω::ΩBase, x::RandVar) = proj(ω, x.id, 1)

proj(ω::O, i...) where {I, O <: ΩBase{I}} = 
  ΩProj{O, I}(ω, base(I, i...))

proj(tω::TaggedΩ, x::RandVar) = tag(proj(tω.taggedω, x), tω.tags)
@spec _res.tags == tω.tags "tags are preserved in projection"

"Project `ω` to `rv` then apply"
@inline apl(rv::RandVar, ω::ΩBase) =  ppapl(rv, proj(ω, rv))

"Reproject back to parent random variable"
@inline apl(rv::RandVar, πω::ΩProj) = apl(rv, parentω(πω))

"Reify arguments (resolve random variables to values)"
@inline reify(ω, args) = map(x -> subapl(x, ω), args)
@spec all([r isa elemtype(a) for (a, r) in zip(args, _res)])

@inline reify(ω, (x1, x2)::Tuple{T1, T2}) where {T1, T2} =
 subapl(x1, ω), subapl(x2, ω)
@inline reify(ω, (x1, x2, x3)::Tuple{T1, T2, T3}) where {T1, T2, T3} =
 subapl(x1, ω), subapl(x2, ω), subapl(x3, ω)
@inline reify(ω, (x1, x2, x3, x4)::Tuple{T1, T2, T3, T4}) where {T1, T2, T3, T4} =
 subapl(x1, ω), subapl(x2, ω), subapl(x3, ω), subapl(x4, ω)


# TODO use generated function to avoid runtime iteration in reify

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
  apl(rv, TaggedΩ(parentω(tω.taggedω), tω.tags))

# Generated funtion for typed dispatch on different tags (might be unnecssary)
@generated function apl(rv::RandVar, tω::TaggedΩ{I, Tags{K, V}, ΩT}) where {I, K, V, ΩT <: ΩBase}
  if hastags(tω, :replmap)
    :(Omega.Causal.replaceapl(rv, tω))
  elseif hastags(tω, :cache)
    :(memapl(rv, tω))
  else
    :(ppapl(rv, proj(tω, rv)))
  end
end
 