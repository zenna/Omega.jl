# I don't like all these ids I have to make.
# 

struct CondRandVar{X, Y} <: RandVar
  x::X
  y::Y
  id::ID
end

"Propagate conditions"
Base.:+(x::CondRandVar, y::CondRandVar, id = uid()) = CondRandVar(x.x + y.x, conjoin(x.y, y.y), id)
conjoin(a::Tuple, b::Tuple) = (a..., b...)

"Requirements are that cah"
struct Observation{X, V}
  x::X
  v::V
end

"""
θ = normal(0, 1)
x = normal(θ, 1)
θ_ = cond(θ, observe(x, 3.0))


θ_ |ₚ (x == 3.0)
θ_ |ᵢ (x => 3.0)
"""
observe(x, v) = Observation(x, v)

cond(x, y::Observation, id = uid()) = CondRandVar(x, (y,), id)

function apl(x::CondRandVar, ω)
  # Need to do a replacement 
end

function logpdf_(x::CondRandVar, ω::Ω)

end