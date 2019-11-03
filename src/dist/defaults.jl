defalg(::typeof(mean), ::RandVar) = SampleMean
defalg(::typeof(mean), ::Prim.PrimRandVar) = Analytic # Fix ambiguities
defalg(dop::DistOp, ::Prim.PrimRandVar) = Analytic

for dop in distops_names
  expr = :($dop(x::RandVar) = $dop(x, defalg($dop, x)))
  eval(expr)
end
