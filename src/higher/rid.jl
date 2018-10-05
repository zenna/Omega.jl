"""Random Interventional Distribution

```jldoctest
μ = uniform([-100.0, 100.0])
x = normal(μ, 1.0)
x_ = rid(x, μ)
```
"""
rid(x::RandVar, θ::RandVar) = ciid(ω -> replace(x, θ => θ(ω)))
rid(x::RandVar, θs::RandVar...) = ciid(ω -> replace(x, (θi => θi(ω) for θi in θs)...))