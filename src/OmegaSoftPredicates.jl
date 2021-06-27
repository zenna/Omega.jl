module OmegaSoftPredicates

import SoftPredicates: AbstractSoftBool
import OmegaCore

OmegaCore.initerror(::Type{T}) where T <: AbstractSoftBool = one(T)

end