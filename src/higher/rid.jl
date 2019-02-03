"""
$(SIGNATURES)

Random Interventional Distribution of `x` given `Θ`

```jldoctest
μ = uniform([-100.0, 100.0])
x = normal(μ, 1.0)
x_ = rid(x, μ)
mean(x_)
```


Given two random variables ``X`` and ``Θ``, the random interventional distribution
of ``X`` given ``Θ`` is a a random distribution (`RandVar` with `elemtype` `RandVar`).
In particular, each realization of ``rid(X, Θ)`` is the random variable ``X`` subject
to the intervention ``Θ = Θ`` where ``Θ ∼ Θ`` is a realization of ``Θ``:

The random interventional distribution of a random variable `X` with elem type `tau_1`
given ``Θ: Ω → τ_2`` is a random variable
``x ∥ do(θ): Ω → (Ω →  τ_1)``, defined as:

``
x ∥ do(θ) = ω → x | do(θ = θ(ω))
``

"""
rid(x::RandVar, θ::RandVar) = ciid(ω -> replace(x, θ => θ(ω)))
rid(x::RandVar, θs::RandVar...) = ciid(ω -> replace(x, (θi => θi(ω) for θi in θs)...))