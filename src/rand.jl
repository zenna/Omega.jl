## Sampling and Inference
## ======================
"Unconditional Sample from `x`"
Base.rand(x::RandVar) = x(Omega())

"Sample from `x | y == true` with rejection sampling"
function Base.rand(x::RandVar, y::RandVar{Bool})
  while true
    ω = Omega()
    if y(ω)
      return x(ω)
    end
  end
end

"Sample from `x | y == true` with rejection sampling"
function Base.rand(x::RandVar, y::RandVar{SoftBool})
  ω = Omega()
  (ω, x(ω), y(ω).epsilon)
end