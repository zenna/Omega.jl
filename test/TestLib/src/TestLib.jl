module TestLib
  include("lens.jl")

  module Omega
    include("omega/space.jl")
  end
end