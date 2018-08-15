module IdGen

using ..Misc

export uid, @id, Id, Ints

const uidcounter = Counter(0)

"Unique id"
uid() = (global uidcounter; increment(uidcounter))

"Construct globally unique id for indices for ω"
macro id()
  uid()
end

#"Index of Probability Space"
const Id = Int

#"Tuple of Ints"
const Ints = NTuple{N, Int} where N

#"Id of a random variable"
#const RandVarId = Int


end