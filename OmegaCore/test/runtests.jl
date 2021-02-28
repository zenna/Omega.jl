using Test
using Pkg
Pkg.develop(path = "../../OmegaTest")

@testset "alltests" begin
  include("typeinfer.jl")
  include("ciid.jl")
  include("condition.jl")
  include("distributions.jl")
  include("core.jl")
  include("intervene.jl")
  include("logpdf.jl")
  include("multivariate.jl")
  include("namedtuple.jl")
  include("solution.jl")
  include("tagging.jl")
  include("typeinfer.jl")
  include("var.jl")
end