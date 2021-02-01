module IDS

using Spec
import ..Util: Counter, increment!, Box, reset!
using DataStructures: LinkedList, cons, nil, list, head, tail
export append, base, combine, increment!, increment,
       Paired, pair
export combine, append, base, increment, firstelem
export withscope, scope, scope!
export ID, @uid, uid, toid

include("idinterface.jl")
include("idtypes.jl")
include("id.jl")

end