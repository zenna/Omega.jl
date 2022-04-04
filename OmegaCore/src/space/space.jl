module Space

using ..Basis
import ..Tagging: hastag, traithastag, tag
import ..Traits: traits

using Spec

# Sample / Parameter Space
# include("pdf.jl")               # Pdf
# include("scope.jl")
include("simpleomega.jl")       # Sample Space / Distributions
include("lazyomega.jl")         # Sample Space / Distributions
# include("linearomega.jl")       # Sample Space / Distributions

# Defaults
Basis.defΩ(args...) =
  LazyΩ{EmptyTags, Dict{Any, Any}}
  ``
Basis.defω(args...) = tagrng(defΩ()(), Random.GLOBAL_RNG)

end