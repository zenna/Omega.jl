
"""
Free Variable

Like random variables, free variables are uncertain values.
Unlike random variables the uncertainty is not quantified,
no more value is more or less likely than any other.

"""
abstract type Var <: NonDetVar end

# Primitive Free Variables
struct Unit{T <: Real} <: Var
  id::ID
end

"`unit(T)` is a random variable over [0, 1]"
unit(::Type{T} = Float64; id = uid()) where T = Unit{T}(id)

solve(::Unit{T}) where T = rand(T)

"Find a solution to all the variables in the model that satisfies"
function solve(x::Var) end

"Find a solution that maps the variable values to free"
function optim(x::Var, ℓ) end