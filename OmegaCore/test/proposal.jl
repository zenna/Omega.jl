using OmegaCore
using Test

(x::StdUnif)(ω) = ω.data[x]




function test()
  x = 1 ~ Normal(0, 1)
  y = 2 ~ Normal(0, 1)
  z = x +ₚ y

  function propose(::typeof(z), z_, ω)
    if x in ω && y ∈ ω
      return nothing
    elseif x ∈ ω
      
      c(x) = cdf(Normal(0, 1), x)
      Dict{Any, Any}(StdUnif(2) => c(x_ - ω.data[μ]))
    elseif StdUnif(2) in keys(ω.data)
      nothing
    end
      ## Provide a value for μ
      # @assert false
  end


  x_ = 3.5
  ω = Ω(Dict{Any, Any}(x => x_))
  propose(μ, ω)
end

function test()
  μ = 1 ~ Normal(0, 1)
  x(ω) = (2 ~ Normal(x(ω), 1))(ω)
  joint = OmegaCore.@joint μ x

  function subpropose1(qω, f, ω)
    # 1. Return new values, which are just merged,
    # with null case being empty set
    # 2. Make it mutative, modify ω
    # 3. 
  end
  qω = OmegaCore.defω()
  ω = OmegaCore.defω()
  cp = CompProposal((stdpropose,))
  ω_ = propose(qω, joint, ω, cp)
end