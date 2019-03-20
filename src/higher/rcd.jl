"""
$(SIGNATURES)

Random Conditional Distribution of `x` given `Θ`.

Random conditional distributions provide a mechanism to condition distributional properties.
Given two random variables ``X`` and ``Θ``, the random conditional distribution of ``X`` given ``Θ`` -- which we denote ``X ∥ Θ`` -- is a a random distribution:
a random variable whose `elemtype` is a random variables.
In particular, each realization of ``X ∥ Θ`` is the random variable ``X`` conditioned on ``Θ = θ`` where ``θ ∼ Θ`` is a realization of ``Θ``:

The random conditional distribution (rcd) of a random variable ``X: Ω → τ_1`` given ``Θ: Ω → τ_2`` is a random variable ``X ∥ Θ:  Ω → ( Ω → τ_1)``, defined as:

``
(x ∥ θ) = ω -> x | (Θ = Θ(ω))
``
"""
rcd(x::RandVar, θ::RandVar, eq = ==ᵣ) =  ciid(ω -> cond(x, eq(θ, θ(ω))))
rcd(x::RandVar, θs::Tuple, eq = ==ᵣ) = rcd(x, randtuple(θs), eq)

"`rcd`, x ∥ θ"
x ∥ θ = rcd(x, θ)

"`rcd` with soft equality"
rcdₛ(x, θ) = rcd(x, θ, ==ₛ)

"`rcd` with soft equality"
x ∥ₛ θ = rcd(x, θ, ==ₛ)