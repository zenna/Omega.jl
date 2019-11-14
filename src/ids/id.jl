# const ID = Int
const IDT = UInt64
const ID = Vector{IDT}
const uidcounter = Counter(IDT)

"Unique id, (scope 1), (scope, 2), ..."
uid(; scope = scope()) = append(scope, increment!(uidcounter))
@spec :nocheck (x = [uid() for i = 1:Inf]; unique(x) == x)

"Construct globally unique id for indices for ω"
macro uid()
  uid()
end

# Scope
const SCOPE = Wrapper(base(ID))
scope()::ID = SCOPE.val

"""
Introduce a scope where `id` is prepended to any id created in this scope
```
withscope(21) do
  x =~ uniform(0, 1)
  y =~ uniform(0, 1)
end
```
"""
function withscope(f, id::ID)
  oldscope = scope()
  scope!(id)
  ret = f()
  scope!(oldscope)
  ret
end

withscope(f, ID) = withscope(f, base(ID, hash(ID)))

"Change the global scope to `id`"
function scope!(id::ID)::ID
  SCOPE.val = id
end

scope!(id) = scope!(base(ID, hash(id)))
