"The Omega Lanaguage (Not Library)"
module Lang

include("oexpr.jl")       # Abstract Syntax tree for Omega
# include("parse.jl")     # Parse Omega from tex
# include("repl.jl")      # Parse Omega from tex
include("compile.jl")     # Compile OmegaLang Expression into shit
include("unparse.jl")     # Convert expression tree into pretty printed syntax
include("expr.jl")        # Convert from Julia Expression to Omegea Expression

end