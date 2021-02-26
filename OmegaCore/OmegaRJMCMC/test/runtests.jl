using OmegaCore
using OmegaRJMCMC
using Distributions

"From Green et. al"
function poissonmodel()
  # Bayesian model over two models
  # 1. Poisson omodel
  # 2. Negative binomeial model

  function f(ω)
    k = 1 ~ DiscreteUniform(1, 2) # model indicator, selects model
    N = 10
    αλ, βλ = 25, 10
    λ = 2 ~ Gamma(αλ, βλ)
    λ_ = λ(ω)
    if k(ω) == 1
      Y = 5 ~ Poisson(λ_)
    else
      ακ, βκ = 1, 10
      κ = (3 ~ Gamma(ακ, βκ))
      κ_ = κ(ω)
      # Distributions has different parameterization
      # https://wiki.analytica.com/index.php?title=Negative_binomial_distribution#Alternate_parameterizations
      Y = 5 ~ NegativeBinomial(κ_, λ_ / (λ_ + κ_))
    end
    Y(ω)
    # Mv(Y, N)(ω)
  end

  # TODO: Mv needs to work
  # TODO: get data for Y
  function h(ω::T) where 
    μ = 0.5
    x = 0.2
    σ = 0.1 # Parameter
    u = Normal(0, σ)
    if ω[κ] == 1
      (k => 2, λ => ω[λ], κ => μ * exp(u))
    else
      (k => 1, )
    end
  end

  randsample((k, λ), Y == Ydata, Constant(h),j, alg = RJMCMC)
  
end

## FIXME / TODO
# Should ω be RandVar -> τ
# or RandVarId -> τ
# 

# randsample(poissonmodel())


#   # This is literal pointwise semanics
#   q(ω) -> Poisson(λ(ω))

#   So that makes sense, but
#   we want kind of parity with parameters
#   Poission(0.4) produces a ciid class
#   lift(Poisson)(λ) produces a distribution over ciid classes
  

#   q(id, ω) = Poisson(λ(ω))(id, ω)

#   into 

#   (id, ω) -> Poisson(_)(id, ω)

#   The problem with this reduction is that we would need to ensure hte \oemgas are consistent

#   What's to stop me form violating that.
#   In this snse i cant see it as a valid independent procedure.

#   u might say the general mechanism is just partial application.


#   I'm not sure what it should produce.
#   On the one hand the lifted notation makes sense because its the literal
#   extention of lifting.

#   On the other hand, the version that produces a `ciid` makes sense too.
#   Practically, if we have Mv(i)

#   Option 1: Partial application-
#   Option 2: specialise to this classes
#   Option 3: just use special types

#   @inline Space.recurse(mv::Mv{<:Distribution}, id, ω) =
#     recurse(Mv(mv.dist(ω)), id, ω)



#   # Model 1