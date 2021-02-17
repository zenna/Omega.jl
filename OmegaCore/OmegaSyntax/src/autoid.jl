module AutoID
# OmegaCore.ciid
# using IRTools
using OmegaCore

@inline OmegaCore.ciid(f) = ciid(f, rand(Int))
@inline Base.:~(f) = ciid(f)

end