"Autumn Language"
module LambdaC
using Reexport


include("aexpr.jl")
@reexport using .AExpressions

include("util.jl")
@reexport using .Util

include("sexpr.jl")
@reexport using .SExpr

include("subexpr.jl")
@reexport using .SubExpressions

# include("passes.jl")

# include("compileutils.jl")
# @reexport using .CompileUtils

# include("compile.jl")
# @reexport using .Compile

# include("abstractinterpretation.jl")
# @reexport using .AbstractInterpretation

include("interpret/interpret.jl")
@reexport using .InterpretBig

# include("interpret/interpret2.jl")
# @reexport using .Interpret2

# include("scope.jl")
# @reexport using .Scope

# include("transform.jl")
# @reexport using .Transform

end
