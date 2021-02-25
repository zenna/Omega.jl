module Space

using ..Basis
import ..Tagging: hastag, traithastag, tag
import ..Traits: traits

# Sample / Parameter Space
# include("abstractomega.jl")     # Abstract sample/Paramter Spaces
# include("pdf.jl")               # Pdf
# include("scope.jl")
include("simpleomega.jl")       # Sample Space / Distributions
include("lazyomega.jl")         # Sample Space / Distributions

# Defaults
Basis.defΩ(args...; idtype = defID()) =
  LazyΩ{EmptyTags, Dict{Any, Any}, idtype}
  ``
Basis.defω(args...) = tagrng(defΩ()(), Random.GLOBAL_RNG)

end