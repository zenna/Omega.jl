module OmegaSoftPredicates

import SoftPredicates: AbstractSoftBool, DualSoftBool, logerr
import OmegaCore

export softconstraints

OmegaCore.initerror(::Type{T}) where T <: AbstractSoftBool = one(T)

softconstraints(x) = OmegaCore.condvar(x, DualSoftBool{Float64}) # zt: should this be fized to float64?
 
end