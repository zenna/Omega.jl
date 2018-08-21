module IdGen

using ..Misc

export uid, @id, ID

const ID = Int

const uidcounter = Counter(0)

"Unique id"
uid() = (global uidcounter; increment!(uidcounter))
@spec :nocheck (x = [uid() for i = 1:Inf]; unique(x) == x)

"Construct globally unique id for indices for ω"
macro id()
  uid()
end

end