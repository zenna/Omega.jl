export Constant

import Distributions: Distribution
import Distributions

struct DiscreteContinuous <: Distributions.ValueSupport
end

traitvariate(::Type{<:AbstractArray}) = Distributions.Multivariate
traitvariate(::Type{<:AbstractMatrix}) = Distributions.Matrixvariate
traitvariate(::Type{<:Tuple}) = Distributions.Multivariate
traitvariate(::Type{T}) where T = Distributions.Univariate

traitcontinuous(::Type{<:Real}) = Distributions.Continuous
traitcontinuous(::Type{<:Integer}) = Distributions.Discrete
traitcontinuous(::Type{<:T}) where T <: AbstractArray = traitcontinuous(eltype(T)) 
traitcontinuous(::Type{<:T}) where T <: Tuple = traitcontinuous(eltype(T))
traitcontinuous(::Type{T}) where T = DiscreteContinuous

# traitcontinuous(::Type{<:Integer}) = Distributions.Discrete

"Constant distribution"
struct Constant{T, F, S} <: Distribution{F, S}
  val::T
  Constant(val::T) where T = new{T, traitvariate(T), traitcontinuous(T)}(val)
end

Distributions.logpdf(c::Constant, x::T) where {T <: Real} = x == c ? one(T) : zero(T)
Distributions.mean(c::Constant{<:Real}) = c.val
Distributions.median(c::Constant{<:Real}) = c.val
Distributions.mode(c::Constant{<:Real}) = c.val
Distributions.var(c::Constant{T}) where {T <: Real} = zero(T)

Base.rand(rng::AbstractRNG, c::Constant) = c.val