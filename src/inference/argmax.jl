defoptimalg(args...) = NLoptArgmax

"ω which maximizes x(ω)" 
function Base.argmax(x::RandVar;
                     alg = defoptimalg(x),
                     ΩT::Type{OT} = defΩ(alg),
                     kwargs...) where {OT <: Ω}
  argmax(x, alg, ΩT; kwargs...)
end