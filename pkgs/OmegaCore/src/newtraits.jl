struct A end
struct B end
struct C end
struct D end
struct E end
struct F end

abstract type T1 end
abstract type T2 <: T1 end
abstract type T3 <: T2 end
abstract type T4 <: T3 end
abstract type T5 <: T4 end
abstract type T6 <: T5 end
abstract type T7 <: T6 end
abstract type T8 <: T7 end

f(::Any) = Union{}
f(::Type{Any}) = Union{}
f(::Type{T}) where T = f(supertype(T))
f(::Type{T1}) = Union{A, f(supertype(T1))}
f(::Type{T2}) = Union{B, f(supertype(T2))}

trait(::Type{Float64}, ::Type{T1}) = A
trait(::Type{Float64}, ::Type{T2}) = B
trait(::Type{T}, ::Type{U}) where {T, U} = 
  trait(T, supertype(U))

struct Trait{T} end

# Can we get the lowest type, at the type level?


traits(::Type{T}) = Union{trait(T, Union{}), traits()}

