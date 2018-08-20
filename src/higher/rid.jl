function distribution(rid)
  # Turn an RID into a distribution
  θs = params(rid.x) ## Issue is that this is wrong
  θs = isconstant.(θs)
  θsc = rand.(θs)
  distribution(func(x), θsc)
end

"""Random Interventional Distribution

```jldoctest
μ = uniform([-100.0, 100.0])
x = normal(μ, 1.0)
x_ = rid(x, μ)
```
"""
rid(x, θ) = ciid(ω -> replace(x, θ => θ(ω)))