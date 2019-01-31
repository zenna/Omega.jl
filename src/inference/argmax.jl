defoptimalg(args...) = NLoptArgmax

"ω which maximizes x(ω)" 
function Base.argmax(x::RandVar;
                     alg = defoptimalg(x),
                     ΩT::Type{OT} = defΩ(alg),
                     cb = donothing,
                     kwargs...) where {OT <: Ω}
  argmax(x, alg, ΩT; cb = cb, kwargs...)
end