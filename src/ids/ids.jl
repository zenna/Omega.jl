module IDS

using Spec
import ..Util: Counter, increment!, Wrapper, reset!
using DataStructures: LinkedList, cons, nil, list, head, tail
export append, base, combine, increment!, increment,
       Paired, pair
export combine, append, base, increment, firstelem
export withscope, scope, scope!
export ID, @uid, uid

include("idinterface.jl")
include("idtypes.jl")
include("id.jl")

end