function handle_let(e::Expr)
  if e.args[1] isa Expr && e.args[1].head == :(=)
    var, body = b.args[1].args
    LambdaExpr(var, oexpr(body))
  else
    error("cannot handle this let expr")
  end
end

function handle_call(e::Expr)
  LambdaExpr(e.args[1], map(oexpr, e.args[2:end]))
end

"Convert `e` into an `OExpr`"
function oexpr(e::Expr)
  if e.head == :let
    handle_Let(e)
  elseif e.head == :call
    handle_call(e)
  end
end

Base.convert(::Type{OExpr}, e::Expr) = oexpr(e)