# Lambda
unparse(lae::LambdaExpr) = "$(lae.vars...) -> $(unparse(lae.body))"

# AppExpr
isinfix(oe::OExpr) = false 
isinfix(s::Symbol) = s in [:+, :-, :*, :/]

function unparse(ae::AppExpr)
  if isinfix(ae.f)
    length(ae.args) == 2 || throw(ArgumentError("Infix Operator but $(length(ae.args)) args"))
    "$(ae.args)[1] $(ae.f) $(ae.args)[2]"
  else
    args = 
    "$(unparse(ae.f)) $(map(unparse, ae.args)...)"
  end
end

unparse(le::LetExpr) = "$(le.var) : $(unparse(le.val))\n$(unparse(le.body))"