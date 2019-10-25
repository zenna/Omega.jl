"Omega Expression"
abstract type OExpr end

struct LambdaExpr <: OExpr
  var::Symbol
  body::OExpr
end

"Function Application Expr"
struct AppExpr <: OExpr
  f::Expr
  args::Vector{Expr}
end

struct LetExpr <: OExpr
  var::Symbol
  val::OExpr
  body::OExpr  
end