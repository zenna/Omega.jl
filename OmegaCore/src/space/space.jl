module Space

using ..Basis
import ..Tagging: hastag, traithastag, tag
import ..Traits: traits

using Spec

# Sample / Parameter Space
# include("abstractomega.jl")     # Abstract sample/Paramter Spaces
# include("pdf.jl")               # Pdf
# include("scope.jl")
include("simpleomega.jl")       # Sample Space / Distributions
include("lazyomega.jl")         # Sample Space / Distributions
# include("linearomega.jl")       # Sample Space / Distributions

# Defaults
Basis.defsubspace() = UInt64

Basis.defΩ(args...; idtype = defsubspace()) =
  LazyΩ{EmptyTags, Dict{Any, Any}, idtype}
  ``
Basis.defω(args...) = tagrng(defΩ()(), Random.GLOBAL_RNG)

end