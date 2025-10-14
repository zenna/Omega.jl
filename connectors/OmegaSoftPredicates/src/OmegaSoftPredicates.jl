module OmegaSoftPredicates

using SoftPredicates
using SoftPredicates: AbstractSoftBool
import OmegaCore
import InferenceBase: to_logerr
using OmegaCore: pw

export softconstraints,
       pwsofteq,
       pwsoftgt,
       pwsoftlt,
       ==̃ₚ,
       >̃ₚ,
       >=̃ₚ,
       <̃ₚ,
       <=̃ₚ


OmegaCore.initerror(::Type{T}) where T <: AbstractSoftBool = one(T)

to_logerr(x::AbstractSoftBool) = SoftPredicates.logerr(x)

softconstraints(x) = OmegaCore.condvar(x, DualSoftBool{Float64}) # zt: should this be fized to float64?

pwsofteq(x, y) = pw(softeq, x, y)
pwsoftgt(x, y) = pw(softgt, x, y)
pwsoftlt(x, y) = pw(softlt, x, y)

const ==̃ₚ = pwsofteq
const >̃ₚ = pwsoftgt
const >=̃ₚ = pwsoftgt
const <=̃ₚ = pwsoftlt
const <̃ₚ = pwsoftlt

export ≊
const ≊ = ==̃ₚ

end