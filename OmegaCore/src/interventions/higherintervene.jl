export  =>ˡ,  =>ʳ, =>ˡʳ, HigherIntervention, hi

struct HigherIntervention{T} <: AbstractIntervention
  f::T
end



"""
`hi(f::RV{RV})`

Higher order intervention.  

If `f` is a variable over interventions then `hi` allows you to intervene
on the variable it points to.

```julia
using OmegaCore, Distributions
μ = 1 ~ Normal(0, 1)
σ = 2 ~ Uniform(1, 3)
y(ω) = (3 ~ Normal(μ(ω), σ(ω)))(ω)
choice(ω) = ifelse((4 ~ Bernoulli(0.5))(ω), μ, σ)
int_dist(ω) = Intervention(choice(ω) => 5.0)

# Want to say the y had the variableof choice been 5
joint = @joint(y_, μ, σ, choice)
joint_ = joint |ᵈ hi(int_dist)
randsample(joint_)
```

"""
hi(f) = HigherIntervention(f)

(hi::HigherIntervention)(ω) = hi.f(ω)

"Random variable over interventions"
struct LR{M, X, V}
  x::X
  v::V
end

LR{M}(x::X, v::V) where M where {X, V} = LR{M, X, V}(x, v)

x =>ˡ v = HigherIntervention(LR{:L}(x, v))

"`x ²¦ v`: `ω -> x(ω) => v`"
x =>ʳ v = HigherIntervention(LR{:R}(x, v))

"`x ²¦² v`: `ω -> x(ω) => v(ω)`"
x =>ˡʳ v = HigherIntervention(LR{:LR}(x, v))

(i::LR{:L})(ω) = Intervention(i.x(ω) => i.v)
(i::LR{:R})(ω) = Intervention(i.x => i.v(ω))
(i::LR{:LR})(ω) = Intervention(i.x(ω) => i.v(ω))