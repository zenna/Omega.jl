module Traits

export traits, trait, Trait

struct Trait{T} end 

"Produces type which will only match those which have trait"
@inline trait(x::Type{X}) where X = Trait{T} where {T >: X}
@inline trait(x1, x2) = trait(Union{x1, x2})
@inline trait(x1, x2, x3) = trait(Union{x1, x2, x3})
@inline trait(x1, x2, x3, x4) = trait(Union{x1, x2, x3, x4})
@inline trait(x1, x2, x3, x4, x5) = trait(Union{x1, x2, x3, x4, x5})
@inline trait(x1, x2, x3, x4, x5, xs...) = trait(Union{x1, x2, x3, x4, x5, xs...})

"`traits(::Type{T}` traits of `T`"
function traits end

end