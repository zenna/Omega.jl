using ..Tagging, ..Traits, ..Var, ..Space, ..Basis
# @inline hasintervene(ω) = hastag(ω, Val{:intervene})

@inline tagintervene(::trait(Intervene), ω, intervention) =
  let i = mergeinterventions(intervention, ω.tags.intervene.intervention)
    mergetag(ω, (intervene = (intervention = i, intctx = ω.tags.intervene),))
  end

@inline tagintervene(trait, ω, intervention) =
  mergetag(ω, (intervene = (intervention = intervention, intctx = NoIntervention()),))

@inline tagintervene(ω, intervention) =
  tagintervene(traits(ω), ω, intervention)
  # tag(ω, (intervene = (intervention = intervention, intctx = ictx(ω),),), mergetags)

@inline Var.recurse(x::Intervened, ω) = x.x(tagintervene(ω, x.i))
# @inline (x::Intervened)(ω) = x.x(tagintervene(ω, x.i))

@inline Var.recurse(x::Intervened{X, <: HigherIntervention}, ω) where X =
  x.x(tagintervene(ω, x.i(ω)))

replaceintervene(ω, intctx) = mergetag(ω, (intervene = intctx,))
rmintervention(ω) = Basis.rmtag(ω, Val{:intervene})

@inline applyintervention(i::ValueIntervention, ω, intctx) = i.v 
@inline applyintervention(i::Intervention, ω, intctx) = i.v(replaceintervene(ω, intctx))
@inline applyintervention(i::Intervention, ω, intctx::NoIntervention) = i.v(rmintervention(ω))

@inline function passintervene(traits, i::Intervention{X, V}, intctx, x::X, ω) where {X, V}
  # If the variable ` x` to be applied to ω is the variable to be replaced
  # then replace it, and apply its replacement to ω instead.
  # Othewise proceed as normally
  if i.x == x
    applyintervention(i, ω, intctx)
    # i.v(replacetags(ω, intctx))
  else
    prepostapply(traits, x, ω)
  end
end

@inline function passintervene(traits, i::ValueIntervention{X, V}, intctx, x::X, ω) where {X, V}
  if i.x == x
    i.v
  else
    prepostapply(traits, x, ω)
  end
end

# @inline function passintervene(traits, i::ValueIntervention{X, V}, intctx, x::X2, ω) where {X, X2, V}
#   @show X, X2
#   @assert false
# end

function passintervene(traits,
  i::Union{MultiIntervention{<:Tuple{SlightlyLessAbstractIntervention{X1, V1},
                                   SlightlyLessAbstractIntervention{X2, V2}}},
           MultiIntervention{<:Tuple{SlightlyLessAbstractIntervention{X1, V1},
                                   SlightlyLessAbstractIntervention{X2, V2},
                                   SlightlyLessAbstractIntervention{X3, V3}}},
           MultiIntervention{<:Tuple{SlightlyLessAbstractIntervention{X1, V1},
                                   SlightlyLessAbstractIntervention{X2, V2},
                                   SlightlyLessAbstractIntervention{X3, V3},
                                   SlightlyLessAbstractIntervention{X4, V4}}},
           MultiIntervention{<:Tuple{SlightlyLessAbstractIntervention{X1, V1},
                                   SlightlyLessAbstractIntervention{X2, V2},
                                   SlightlyLessAbstractIntervention{X3, V3},
                                   SlightlyLessAbstractIntervention{X4, V4},
                                   SlightlyLessAbstractIntervention{X5, V5}}}},
  intctx,
  x::Union{X1, X2, X3, X4, X5},
                       ω) where {X1, X2, X3, X4, X5, V1, V2, V3, V4, V5}
  if x == i.is[1].x
    # i.is[1].v(ω)
    applyintervention(i.is[1], ω, intctx)
  elseif x == i.is[2].x
    # i.is[2].v(ω)
    applyintervention(i.is[2], ω, intctx)
  elseif length(i.is) >= 3 && x == i.is[3].x
    # i.is[3].v(ω)
    applyintervention(i.is[3], ω, intctx)
  elseif length(i.is) >= 4 && x == i.is[4].x 
    # i.is[4].v(ω)
    applyintervention(i.is[4], ω, intctx)
  elseif length(i.is) >= 5 && x == i.is[5].x
    # i.is[5].v(ω)
    applyintervention(i.is[5], ω, intctx)
  else
    prepostapply(traits, x, ω)
  end
end

function passintervene(traits,
                       i::MultiIntervention{XS},
                       tags,
                       x,
                       ω) where XS
  index = 1;
  while (index <= length(i.is) && x != i.is[index].x)
    index += 1
  end
  if (index <= length(i.is))
    i.is[index].v(ω)
  else
    prepostapply(traits, x, ω)
  end
end


# We only consider intervention if the intervention types match
@inline passintervene(traits, i::AbstractIntervention, intctx, x, ω) =
  prepostapply(traits, x, ω)

Var.dispatch(traits::trait(Intervene), f, ω::AbstractΩ) = 
  passintervene(traits, ω.tags.intervene.intervention, ω.tags.intervene.intctx, f, ω)