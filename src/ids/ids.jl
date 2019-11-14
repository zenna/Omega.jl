module IDS

using Spec
import ..Util: Counter, increment!

export ID, @uid, uid

const ID = Int

const uidcounter = Counter(0)

# # __init__() = global uidcounter = Counter(0) #= also works =#
# __init__() = reset!(uidcounter)

"Unique id"
# uid() = (global uidcounter; @show increment!(uidcounter))
uid() = increment!(uidcounter)

@spec :nocheck (x = [uid() for i = 1:Inf]; unique(x) == x)

"Construct globally unique id for indices for ω"
macro uid()
  uid()
end

"""
Introduce a scope where `id` is prepended to any id created in this scope


```
scope(21) do
  x =~ uniform(0, 1)
  y =~ uniform(0, 1)
end
```
"""
function scope(f, id::ID)
  # Issues variables are not in scope
  # Could have a scope!() which juse changes
  # The other issue is that we can still clash IDs
end

function scope!(id::ID)
end

scope!(id) = scope!(hash(id))

end