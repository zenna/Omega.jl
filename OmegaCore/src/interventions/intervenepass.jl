using ..Tagging, ..Traits, ..Var, ..Space
# @inline hasintervene(ω) = hastag(ω, Val{:intervene})

ictx(traits::trait(Intervene), ω) = ω.tags.intervene
ictx(traits, ω) = NoIntervention()
ictx(ω) = uctx(traits(ω), ω)

@inline tagintervene(ω, intervention) =
  tag(ω, (intervene = (intervention = intervention, intctx = ictx(ω)), mergetags))
@inline (x::Intervened)(ω) = x.x(tagintervene(ω, x.i))
@inline (x::Intervened{X, <:HigherIntervention})(ω) where X =
  x.x(tagintervene(ω, x.i(ω)))

replaceintctx(ω, intctx)

@inline applyintervention(i::ValueIntervention, ω, intctx) = i.v 
@inline applyintervention(i::Intervention, ω, intctx) = i.v(replaceintctx(ω, intctx))

@inline function passintervene(traits, i::Intervention{X, V}, intctx, x::X, ω) where {X, V}
  # If the variable ` x` to be applied to ω is the variable to be replaced
  # then replace it, and apply its replacement to ω instead.
  # Othewise proceed as normally
  if i.x == x
    i.v(replacetags(ω, intctx))
  else
    ctxapply(traits, x, ω)
  end
end

@inline function passintervene(traits, i::ValueIntervention{X, V}, intctx, x::X, ω) where {X, V}
  if i.x == x
    i.v
  else
    ctxapply(traits, x, ω)
  end
end

function passintervene(traits,
                       i::Union{MultiIntervention{Tuple{SlightlyLessAbstractIntervention{X1, V1},
                                                        SlightlyLessAbstractIntervention{X2, V2}}},
                                MultiIntervention{Tuple{SlightlyLessAbstractIntervention{X1, V1},
                                                        SlightlyLessAbstractIntervention{X2, V2},
                                                        SlightlyLessAbstractIntervention{X3, V3}}},
                                MultiIntervention{Tuple{SlightlyLessAbstractIntervention{X1, V1},
                                                        SlightlyLessAbstractIntervention{X2, V2},
                                                        SlightlyLessAbstractIntervention{X3, V3},
                                                        SlightlyLessAbstractIntervention{X4, V4}}},
                                MultiIntervention{Tuple{SlightlyLessAbstractIntervention{X1, V1},
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
    applyintervention(i.is[2], ω, intctx)
  elseif length(i.is) >= 4 && x == i.is[4].x 
    # i.is[4].v(ω)
    applyintervention(i.is[4], ω, intctx)
  elseif length(i.is) >= 5 && x == i.is[5].x
    # i.is[5].v(ω)
    applyintervention(i.is[5], ω, intctx)
  else
    ctxapply(traits, x, ω)
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
    ctxapply(traits, x, ω)
  end
end


# We only consider intervention if the intervention types match
@inline passintervene(traits, i::AbstractIntervention, x, ω) =
  ctxapply(traits, x, ω)

(f::Vari)(traits::trait(Intervene), ω::AbstractΩ) = 
  passintervene(traits, ω.tags.intervene.intervention, ω.tags.intervene.intctx, f, ω)