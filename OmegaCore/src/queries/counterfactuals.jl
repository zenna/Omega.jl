export cf, fc, cndint

"""
`cf(x, y, i::Intervention)`

Counterfactual: Given that `y` is true, what would `x` had been `i` been true 

```math
(x \\mid y) \\mid \\text{do}(I)))

# Example

```
using OmegaCore, Distributions
p = 0.7
q = 0.3
order = 1 ~ Bernoulli(p)        # court orders execution wiht prob. p
Anerves = 2 ~ Bernoulli(q)      # rifleman A shoots with prob. q out of nervousness
Ashoots = order |ₚ Anerves
Bshoots = order
dead = Ashoots |ₚ Bshoots

# If the prisoner is dead, then the prisoner would be dead even if rifleman A had not shot
dead_cf = cf(dead, dead, Ashoots => false)
dead_cf = (dead |ᶜ Ashoots) |ᵈ (Ashoots => false)
```
"""
cf(x, y, i::AbstractIntervention) = (x |ᵈ i) |ᶜ y
# cf(x, y, i::AbstractIntervention) = intervene(cnd(x, y), i)
# cf(x, y, i::AbstractIntervention) =
#   let xi = x |ᵈ i 
#     ω -> condf(ω, xi, y)
#   end
#   #  Bool(y(ω)) ? (x |ᵈ i)(ω) : throw(ConditionException)
cf(x, y, i...) = cf(x, y, Intervention(i...))

"""
`fc(x, y, i::Intervention)`

If in a the hypothetical world `i`, `y` were true, then what is the value of `x`   


```math
x \\mid (y \\mid \\text{do}(I)))
```
# Example
```
using Distributions
order = 1 ~ Bernoulli(0.5)
Anerves = 2 ~ Bernoulli(0.5)
Ashoots = order |ₚ Anerves
Bshoots = order
dead = Ashoots |ₚ Bshoots

# If hypothetically rifleman `C` firing were to kill `B`, then `A` did not fire.
Afc = fc(Bshoots, dead, Ashoots => false)
```

"""
# fc(x, y, i::AbstractIntervention) = cnd(x, intervene(y, i))
fc(x, y, i::AbstractIntervention) =
  let yi = y |ᵈ i
    ω -> condf(ω, x, yi)
  end
fc(x, y, i...) = fc(x, y, Intervention(i...))


"""
`cndint(i::RV{<:Intervention}, y::RV) = i |ᶜ ω -> yi = y |ᵈ i(ω); yi(ω)`

Conditional intervention: conditional random variable over intervention `i`
such that `y | do(i)` is true.


# Example
```
using Distributions
x = 1 ~ Normal(0, 1)
y = 2 ~ Normal(0, 1)
e(ω) = x(ω) + y(ω) >= 11.0

# Construct distribution over interventions
x_ = 3 ~ Uniform(0, 10)
i = ω -> x => x_(ω)
icond = cndint(i, e)

# Sample from distribution over interventions such that ...
# doing that intervention will ensure that `e` is true
julia> randsample(icond, 3)
julia> randsample(icond, 3)
3-element Vector{Pair{Member{Normal{Float64}, Vector{Int64}}, Float64}}:
 [1]@Normal{Float64}(μ=0.0, σ=1.0) => 9.37047390742177
 [1]@Normal{Float64}(μ=0.0, σ=1.0) => 9.409378254490608
 [1]@Normal{Float64}(μ=0.0, σ=1.0) => 8.769913889437522

```

"""
cndint(i, y) = i |ᶜ (ω -> (y |ᵈ i(ω))(ω))