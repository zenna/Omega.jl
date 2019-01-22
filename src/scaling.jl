# Make this work
# 1. Need a good example
# 2. Plot both preds in plotscalar
# 3. Isssue is this is whatif we get into a satisfying region?

# May be more than one gamma per constraint

function softeqgamma(γ0 = 1.0)
  γ = Ref(γ0)
  function op(x, y, k = Omega.globalkernel())
    SoftBool(k(Omega.d(x, y) * (γ.x)))
  end
  (op = lift(op), γ = γ)
end

# Moving Averages
"Exponential moving average"
function ema(α)

end


# Callbacks

struct EMA
  vals::Array{Float64}
end

function Base.push!(ema::EMA, val)
  push!(ema.vals, val)
end

average(ema::EMA) = Statistics.mean(ema.vals)


"Callback that updates `γs` to minimize the `var([E[pred] for pred in preds])`"
function updatescales(preds, γs, windowsize)
  @pre length(γs) == length(preds) + 1
  weights = Array{Float64}(undef, length(preds), length(windowsize))
  emas = [EMA() for i = 1:length(preds)]
  function updateγs(data, IterEnd)
    predvals = applymany(preds, ω)
    for pred in predvals

      push()
    end
    diffs = averages[2:end] .- averages[1]

  end
end

function test()
  x = uniform(-100, 100)
  y = uniform(-100, 100)
  op, γ = softeqgamma()
  ==ᵧ = lift(op)

  p1 = x ==ₛ 0.0
  p2 = y ==ᵧ 0.0
  rand((p1, p2), p1 & p2, cb = updatescales([p1, p2], γ, 10))
end

# 1. Plot two densities
