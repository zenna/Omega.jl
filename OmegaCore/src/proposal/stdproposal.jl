# This proposal samples from prior and updates exogenous variables
# Using inverse transform 

function stdproposal(qω, x::Member{<:PrimDist}, ω)
  if x in keys(ω.data)
    nothing
  else
    x_ = rand(qω, x.class)
    @show x => x_
  end
end

stdproposal(qω, x, ω) = nothing

function stdproposal(qω, x::Member{<:Distribution}, ω)
  @show x
  display(ω)
  @show ω.data[x]
  if x in keys(ω)
    @show "here"
    @assert false
  else
    @show "not here"
    @assert false
  end
end