"Random Variable: a function `Ω -> T`"
abstract type RandVar{T} end  # FIXME : Rename to RandVar

const ID = Int

# "Distribution Family"
# abstract type Dist end

# "Unknown distribution"
# abstract type Unknown <: Dist end

"Construct `RandVar{TNEW}` from `RandVar{TOLD}`, useful when `TNEW` is poorly inferred."
function newtype(x::RandVar{TOLD}, ::Type{TNEW}) where {TOLD, TNEW}
  RandVar{TNEW}()
end
