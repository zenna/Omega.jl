defalg(::typeof(mean), ::RandVar) = SampleMean
defalg(::typeof(mean), ::Prim.PrimRandVar) = Analytic # Fix ambiguities
defalg(::typeof(mean), ::ReplaceRandVar{A,R2} where R2<:RandVar where A<:Prim.PrimRandVar) = Analytic

defalg(dop::DistOp, ::Prim.PrimRandVar) = Analytic
defalg(dop::DistOp, ::ReplaceRandVar{<:Prim.PrimRandVar}) = Analytic
# defalg(dop::DistOp, ::ReplaceRandVar{<:RandVar, RandVar}) = Analytic

for dop in distops_names
  expr = :($dop(x::RandVar) = $dop(x, defalg($dop, x)))
  eval(expr)
end
